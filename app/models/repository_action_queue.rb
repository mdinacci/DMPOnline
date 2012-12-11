class RepositoryActionQueue < ActiveRecord::Base
  
  extend ActionView::Helpers::NumberHelper #using number_to_human_size function
  
  belongs_to :repository
  belongs_to :user
  belongs_to :plan
  belongs_to :phase_edition_instance
  default_scope order('id DESC')
  
  validates :repository_id, :presence => true #If you delete a repository, you should delete its queue first
  validates :repository_action_type, :presence => true    
  validates :repository_action_status, :presence => true

  # APPEND ONLY - DO NOT CHANGE ORDER
  ACTION_TYPE = %w[none create_metadata create_metadata_media replace_media add_media finalise duplicate delete]
  ACTION_STATUS = %w[none initialising pending processing failed_requeue failed_terminated success removed]

  def type=(action_type)
    self.repository_action_type = RepositoryActionQueue.action_type_id(action_type)
  end
  
  def type
    RepositoryActionQueue.action_type_sym(self.repository_action_type.to_i)
  end
  
  def status=(action_status)
    self.repository_action_status = RepositoryActionQueue.action_status_id(action_status)
  end
  
  def status
    RepositoryActionQueue.action_status_sym(self.repository_action_status.to_i)
  end
  
  def prepend_log(str)
    self.repository_action_log = "#{str}#{self.repository_action_log}"
  end
  
  
  # Get a list of the latest repository queue actions
  def self.latest_entries(limit = Rails.application.config.repository_log_length)
    all limit: limit, 
        order: "id DESC", 
        include: [:user, :plan, :phase_edition_instance]
  end
  
  def self.latest_entry
    first order: "id DESC", 
          include: [:user, :plan, :phase_edition_instance]
  end
  
  def self.latest_entry_for_media_deposit
    conditions = {repository_action_type: [action_type_id(:create_metadata_media), action_type_id(:replace_media), action_type_id(:add_media)]}
    
    first conditions: conditions,
          order: "updated_at DESC, created_at DESC"
  end
  
  def self.with_deposited_media
    where(repository_action_type: [action_type_id(:create_metadata_media), action_type_id(:replace_media), action_type_id(:add_media)])
    .where('repository_action_status <> ?', action_status_id(:failed_terminated))
  end
  def self.has_deposited_media?
    with_deposited_media.exists?    
  end

  def self.with_deposited_metadata
    where(repository_action_type: [action_type_id(:create_metadata), action_type_id(:create_metadata_media), action_type_id(:duplicate)])
    .where('repository_action_status <> ?', action_status_id(:failed_terminated))
  end
  def self.has_deposited_metadata?
    with_deposited_metadata.exists?
  end
  
  # Cannot store URI in advance of action (except for delete), as then it's not possible to create + update without queue running in between.
  def self.enqueue(repository_action_type, plan, phase_edition_instance = nil, user = nil, files = [])

    # When repository_action_uri is null, this means work it out on the fly (i.e. when the queue is processed, not when the item is queued)
    # When it is set (e.g. for deletes), use it. It is necessary to cache the URI for deletes because the original record will have been removed from the system
    
    case repository_action_type
    when :delete
      # Users can change the repository so there could be a range of repositories involved
      repository_list = plan.repository_action_queues.select("DISTINCT repository_action_queues.repository_id").all.collect{|x| [x.repository_id, nil]}
    
      # Mark all existing queue records as removed across all possible repositories
      RepositoryActionQueue.update_all({plan_id: nil, phase_edition_instance_id: nil, repository_action_status: action_status_id(:removed)}, {plan_id: plan.id})
      
      # If the existing plan has never been deposited in the repository, just exit. Otherwise, queue delete.
      if (plan.repository_entry_edit_uri.blank?)
        return
      end
      repository_action_uri = plan.repository_entry_edit_uri
      plan_id = nil
    when :finalise
      repository_action_uri = nil
      plan_id = plan.id
      repository_list = plan.repository_action_queues.with_deposited_media.select("DISTINCT repository_action_queues.repository_id, repository_action_queues.phase_edition_instance_id").all.collect{|x| [x.repository_id, x.phase_edition_instance_id]}
    else
      repository_action_uri = nil
      plan_id = plan.id
      pei_id = phase_edition_instance ? phase_edition_instance.id : nil
      repository_list = [[plan.repository_id, pei_id]]
    end

    repository_list.each do |repository_id, phase_edition_instance_id|
      #Create a queue record
      queue_entry = RepositoryActionQueue.create!({
        repository_id: repository_id,
        plan_id: plan_id,
        phase_edition_instance_id: phase_edition_instance_id,
        user_id: user.id,
        type: repository_action_type,
        status: :initialising,
        repository_action_uri: repository_action_uri,
        repository_action_log: log_message('initialised'),
        retry_count: 0
      }, without_protection: true)

      #If there are files, put them in a bag and zip them up
      if (files.length > 0)
        queue_entry.prepend_log log_message('archiving', files.length)
        
        #Create the temporary file area
        bagit_path = Rails.application.config.repository_path.join('queue', queue_entry.id.to_s)
        FileUtils.mkdir_p(bagit_path)
  
        # make a new bag at base_path
        bag = BagIt::Bag.new(bagit_path)
  
        #Export the files to the bag
        files.each do |file|
          bag.add_file(file[:filename]) do |io|
            io.binmode if (file[:binary])
            io << file[:data]
          end
          queue_entry.prepend_log log_message('bagged', file[:filename], number_to_human_size(file[:data].length))
        end
  
        # generate the manifest and tagmanifest files
        bag.manifest!      
  
        # Now zip it all up
        zipfilename = Rails.application.config.repository_path.join('queue',"dmp#{queue_entry.id}.zip").to_s
        Zip::ZipFile.open(zipfilename, Zip::ZipFile::CREATE) do |zipfile|
          add_directory_to_zipfile(bagit_path, bagit_path, zipfile)
        end
        
        # Remove the old bagit folder
        FileUtils.rm_rf bagit_path
        
        queue_entry.prepend_log log_message('zip_archive', File.basename(zipfilename), number_to_human_size(File.size(zipfilename)))
      else
        queue_entry.prepend_log log_message('no_archive')
      end
        
      
      # Update queue entry to pending
      queue_entry.status = :pending
      queue_entry.save!
    end
  end


  # Use rake to call this on a scheduled basis.  See lib/tasks/dmponline.rake
  def self.process
    message = ActiveRecord::Base.send(:sanitize_sql_array, ["%s", log_message('resubmitted')])
    
    requeue_count = 
      RepositoryActionQueue
        .joins(:repository)
        .where(repository_action_status: action_status_id(:failed_requeue))
        .update_all("repository_action_status = #{action_status_id(:pending)}, retry_count = retry_count + 1, repository_action_log = CONCAT('#{message}', repository_action_log)")
    
    logger.info "Requeued #{requeue_count} failed process(es)" if (requeue_count > 0)
    
    queue_items = self.all(
      conditions: {repository_action_status: action_status_id(:pending)},
      order: "id ASC") #first in, first out

    if (queue_items.count > 0)
      logger.info "There are #{queue_items.count} item(s) in the queue to process"
    else
      logger.info "The queue is empty"
    end

    queue_items.each do |item|
      begin #exceptions could be generated here
        logger.info "Processing #{item.id}"        

        deposit_receipt = nil #clear out previous receipt

        # Record item as being processed
        item.status = :processing
        item.prepend_log log_message('processing')
        item.save!

        connection = item.repository.get_connection(item.user.repository_usernames.for_repository(item.repository))
        
        media_filepath = Rails.application.config.repository_path.join('queue', "dmp#{item.id}.zip").to_s
        media_exists = File.exists?(media_filepath)
        media_content_type = "application/zip"


        # Now process the queue according to the type
        case item.type
          # Creating a metadata only record (no files)
          # Creating a metadata + files record
          # Duplicating a record
          when :create_metadata, :create_metadata_media, :duplicate
            # If the queue's repository_action_uri is set, use it, otherwise use the repository's Collection URI
            item.repository_action_uri ||= item.repository.sword_collection_uri
            item.prepend_log log_message('repository_collection_uri_html', item.repository_action_uri.to_s)

            collection = ::Atom::Collection.new(item.repository_action_uri, connection)

            entry = Atom::Entry.new()
            entry.title = item.plan.project
            summary = "Data management plan.";
            summary += " Lead organisation: #{item.plan.lead_org}." if item.plan.lead_org.strip.present?
            summary += " Start date: #{item.plan.start_date.to_s("%F")}." if item.plan.start_date.present?
            entry.summary = summary
            entry.add_dublin_core_extension!("relation", item.plan.source_plan.repository_entry_edit_uri) if item.plan.source_plan #Store duplicate relation
            entry.updated = Time.now
          
            slug = "#{item.plan.project.parameterize}_#{Time.now.strftime("%FT%H-%M-%S")}"
          
            if item.type == :create_metadata_media
               if media_exists
                  deposit_receipt = collection.post_multipart!(entry: entry, slug: slug, in_progress: true, filepath: media_filepath, content_type: media_content_type)
                else
                  # Throw an error - requested an create with media but the media could not be found
                  raise "Media file #{media_filepath} could not be found. Check value of config.repository_path in config/initializers/dmponline.rb"
                end
            else
                deposit_receipt = collection.post!(entry: entry, slug: slug, in_progress: true)
            end

            if deposit_receipt && deposit_receipt.has_entry
              updates = {}
              updates[:repository_content_uri] = deposit_receipt.entry.content.src if deposit_receipt.entry.content && deposit_receipt.entry.content.src
              updates[:repository_entry_edit_uri] = deposit_receipt.entry.entry_edit_uri if deposit_receipt.entry.entry_edit_uri
              updates[:repository_edit_media_uri] = deposit_receipt.entry.edit_media_links.first.href if deposit_receipt.entry.edit_media_links.length > 0
              updates[:repository_sword_edit_uri] = deposit_receipt.entry.sword_edit_uri if deposit_receipt.entry.sword_edit_uri
              updates[:repository_sword_statement_uri] = deposit_receipt.entry.sword_statement_links.first.href if deposit_receipt.entry.sword_statement_links.length > 0
              # We need to bypass validation for this update
              Plan.where(id: item.plan_id).update_all(updates)

              item.repository_action_receipt = deposit_receipt.entry.to_xml.to_s

              item.prepend_log log_message('repository_content_uri_html', item.plan.repository_content_uri) if item.plan.repository_content_uri
              item.prepend_log log_message('repository_entry_edit_uri_html', item.plan.repository_entry_edit_uri) if item.plan.repository_entry_edit_uri
              item.prepend_log log_message('repository_edit_media_uri_html', item.plan.repository_edit_media_uri) if item.plan.repository_edit_media_uri
              item.prepend_log log_message('repository_sword_edit_uri_html', item.plan.repository_sword_edit_uri) if item.plan.repository_sword_edit_uri
              item.prepend_log log_message('repository_sword_statement_uri_html', item.plan.repository_sword_statement_uri) if item.plan.repository_sword_statement_uri
          
              item.status = :success
              item.prepend_log log_message('completed')
            else
              logger.info "Requeueing because no deposit receipt"
              item.prepend_log log_message('no_deposit_receipt')    
              raise log_message('no_deposit_receipt')
            end


          # Performing an export (with files)
          when :replace_media, :add_media
            # If the queue's repository_action_uri is set, use it, otherwise use the plan's Edit Media URI
            item.repository_action_uri ||= item.plan.repository_edit_media_uri
            item.prepend_log log_message('repository_edit_media_uri_html', item.repository_action_uri) if item.repository_action_uri
          
            entry = Atom::Entry.new()
            entry.links.new(href: item.repository_action_uri.to_s, rel: "edit-media")
          
            # Metadata should be coming from the RDF file within the zip-bagit file
          
            if media_exists
              if item.type == :replace_media
                deposit_receipt = entry.put_media!(
                  filepath: media_filepath,
                  content_type: media_content_type,
                  connection: connection,
                  metadata_relevant: item.repository.filetype?(:rdf)  #Metadata is relevant if the repository is configured to generate RDF on deposits
                )
              else
                #Post (add)
                deposit_receipt = entry.post_media!(
                  filepath: media_filepath,
                  content_type: media_content_type,
                  connection: connection,
                  metadata_relevant: item.repository.filetype?(:rdf)  #Metadata is relevant if the repository is configured to generate RDF on deposits
                )
              end
            
              item.repository_action_receipt = deposit_receipt.entry.to_xml.to_s if deposit_receipt.has_entry
            
            else
              # Raise an error - requested an export but the media could not be found
              raise "Media file #{media_filepath} could not be found. Check value of config.repository_path in config/initializers/dmponline.rb"
            end
          
            item.status = :success
            item.prepend_log log_message('completed')

        
          when :finalise
            # If the queue's repository_action_uri is set, use it, otherwise use the plan's Sword Edit URI
            item.repository_action_uri ||= item.plan.repository_sword_edit_uri
            item.prepend_log log_message('repository_sword_edit_uri_html', item.repository_action_uri) if item.repository_action_uri

            entry = Atom::Entry.new()
            deposit_receipt = entry.post!(:sword_edit_uri => item.repository_action_uri.to_s, :in_progress => false, :connection => connection)
            if deposit_receipt.has_entry
              item.repository_action_receipt = deposit_receipt.entry.to_xml.to_s            
            end

            item.status = :success
            item.prepend_log log_message('completed')      


          when :delete
            # If the queue's repository_action_uri is set, use it, otherwise use the plan's Sword Edit URI
            if item.repository_action_uri.blank?
              raise "Cannot delete item as the repository_action_uri has not been set"
            end

            item.prepend_log log_message('repository_entry_edit_uri_html', item.repository_action_uri) if item.repository_action_uri
          
            entry = Atom::Entry.new()
            deposit_receipt = entry.delete!(:entry_edit_uri => item.repository_action_uri.to_s, :connection => connection)

            if deposit_receipt.has_entry
              item.repository_action_receipt = deposit_receipt.entry.to_xml.to_s            
            end
          
            item.status = :success
            item.prepend_log log_message('completed')      


          else
            item.status = :failed_terminated
            item.prepend_log log_message('failed_terminated', item.repository_action_type.name)
         
        end
        item.save!
        
      rescue Exception => msg
        logger.error msg
        # Contents of msg not really suitable for display to user, so generic message for log
        item.prepend_log log_message('error')
        
        if item.retry_count + 1 < Rails.application.config.repository_queue_retries
          item.status = :failed_requeue
          item.prepend_log log_message('re_attempt')
          item.prepend_log log_message('attempt_count', item.retry_count + 1, Rails.application.config.repository_queue_retries)
          logger.warn "Requeued item #{item.id}"
        else
          item.status = :failed_terminated
          item.prepend_log log_message('terminated')
          item.prepend_log log_message('attempt_count', item.retry_count + 1, Rails.application.config.repository_queue_retries)

          #Send email
          Notifier.report_queue_error(item, msg).deliver
        end

        item.save!
      end    #end of exceptions could be generated here
      
    end #queue_items.each
    
    queue_items.count
  end

  
  private
  
  #Helper functions
  
  def self.add_directory_to_zipfile(directory, base_directory, zipfile)
    directory.children(true).each do |entry|
      relative_entry = entry.relative_path_from(base_directory)
      if (entry.file?)
        zipfile.add(relative_entry.to_s, entry.to_s)
      elsif (entry.directory?)
        zipfile.mkdir(relative_entry.to_s)
        add_directory_to_zipfile(entry, base_directory, zipfile) #recursion!
      end
    end #each    
  end #def
  
  def self.log_message(message, arg1 = nil, arg2 = nil)
    return "#{Time.now.localtime.to_s(:repository_time)}: #{I18n.t("repository.log_message.#{message}", arg1: arg1, arg2: arg2)}\n" 
  end
  
  def self.action_type_id(type)
    ACTION_TYPE.index(type.to_s)
  end
  
  def self.action_type_sym(type)
    ACTION_TYPE[type.to_i].to_sym
  end

  def self.action_status_id(status)
    ACTION_STATUS.index(status.to_s)
  end
  
  def self.action_status_sym(status)
    ACTION_STATUS[status.to_i].to_sym
  end

end
