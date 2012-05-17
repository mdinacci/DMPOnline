class Api::V1::AnswersController < Api::V1::BaseController
  load_and_authorize_resource :edition
  load_and_authorize_resource :through => :edition
  
  # GET api/v1/answers
  def index
    if params[:question_key].blank?
      @answers = []
      @error = 'Invalid parameters'
      status = :bad_request
    else
      @answers = @answers.includes(:phase_edition_instance => {:template_instance => {:plan => :user}})
                    .where('answers.question_id = ? OR answers.dcc_question_id = ?', params[:question_key].to_i, params[:question_key].to_i)
                    .where('phase_edition_instances.edition_id = ?', @edition.id)
                    .where('users.id IS NOT NULL')
      status = :ok
    end
    
    render :index, status: status, layout: false
  end

  # PUT api/v1/answers/1
  def update
    if @answer.phase_edition_instance.edition_id != @edition.id
      @error = 'Not found'
      status = :not_found
    else
      multi = (@answer.all_live_occurrences.count > 1)
      if @answer.phase_edition_instance.template_instance.plan.locked
        @error = 'User has locked plan.  Will not update.'
        status = :conflict
        @lock = 1
      elsif @answer.answered && multi
        @error = 'Existing answer in use in other templates and so locked.  Will not update.'
        status = :conflict
        @lock = 1
      else
        @lock = 0
        if params.has_key?(:answer)
          @answer.update_attributes(:answer => params[:answer])
          if @answer.answered && multi
            @lock = 1
          end
          status = :ok
        else
          @error = 'Invalid parameters'
          status = :bad_request
        end
      end
    end

    render :show, status: status, layout: false
  end

end
