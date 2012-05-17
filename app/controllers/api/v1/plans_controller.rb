class Api::V1::PlansController < Api::V1::BaseController
  load_and_authorize_resource :edition
  load_and_authorize_resource :through => :edition
  helper :phase_edition_instances

   
  # POST api/v1/templates/1
  def create
    status = :ok
    @error = ''
    
    if @edition.state != :published
      @error = 'Template phase version is not published'
      status = :bad_request
      
    else
      if params.has_key?(:xml)
        xml = Nokogiri.XML(params[:xml])
        
        unless xml.at_xpath('//dmp').nil?
          @plan = Plan.new
          
          if xml.at_xpath('//dmp/owner').blank?
            @error = "Owner entity is required"
            status = :bad_request
          else
            pw = rand(36**8).to_s(36)
            owner = User.find_or_initialize_by_email(email: xml.at_xpath('//dmp/owner').content, password: pw, password_confirmation: pw)
            if owner.new_record?
              # TODO: Custom email notification to added users
              owner.skip_confirmation!
              owner.save
            end
            if owner.id.blank?
              @error = "Owner not found"
              status = :not_found
            else
              @plan.user_id = owner.id
            end
          end
          
          if xml.at_xpath('//dmp/project_name').blank?
            @error = "Project name is required"
            status = :bad_request
          else
            @plan.project = xml.at_xpath('//dmp/project_name').content
          end
          
          if @error.blank?
            @plan.lead_org = xml.at_xpath('//dmp/lead_org').try(:content)
            @plan.other_orgs = xml.at_xpath('//dmp/other_orgs').try(:content)
            @plan.start_date = xml.at_xpath('//dmp/project_start').try(:content)
            @plan.end_date = xml.at_xpath('//dmp/project_end').try(:content)
            @plan.budget = xml.at_xpath('//dmp/budget').try(:content)
            @plan.currency_id = Currency.find_by_iso_code(xml.at_xpath('//dmp/currency').try(:content)).id
            @plan.template_ids = [@edition.phase.template_id]
  
            unless @plan.save
              @error = @plan.errors.full_messages.join(". ")
              status = :bad_request
            else
              xml.xpath('//dmp/questions/answer').each do |r|
                q_id = r.attr('question_key') || 0
                a = @plan.answers.where('(answers.question_id = ? AND answers.dcc_question_id IS NULL) OR answers.dcc_question_id = ?', q_id, q_id).first
                unless a.nil?
                  a.update_attributes(:answer => r.content)
                end
              end
            end
          end
        end

      else
        @error = 'Invalid parameters'
        status = :bad_request
      end
    end

    render :show, status: status, layout: false   
  end
  
end
