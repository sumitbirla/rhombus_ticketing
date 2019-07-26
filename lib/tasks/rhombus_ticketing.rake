require 'net/pop'
require 'mail'
require 'fileutils'

namespace :rhombus_ticketing do
  
  desc "Read customer service emails from a POP3 mailbox"
  task inbox: :environment do  
    # @logger = Logger.new(Rails.root.join("log", "crm.log"))
    @logger = Logger.new(STDOUT)
      
    CaseQueue.where(pop3_enabled: true).each do |q|
      
      Net::POP3.enable_ssl(OpenSSL::SSL::VERIFY_NONE) if q.pop3_use_ssl
    
      Net::POP3.start(q.pop3_host, q.pop3_port, q.pop3_login, q.pop3_password) do |pop|
        pop.each_mail { |mail| process_message(q, mail) } 
      end  
    
    end  # each queue
  end
  
  
  # Parse single email message and put in database
  def process_message(q, mail)
    msg = Mail.new(mail.pop(''.dup))  # Ruby 2.5 bug requires .dup to fix
    @logger.debug msg.from.to_s + " => " + msg.to.to_s + "[#{msg.subject}]"
    
    desc = (msg.multipart? ? msg.text_part.decoded : msg.body.decoded)
     
    # embedded case ID found in email?
    m = /case:::\d{5}:::/.match(desc) 

    if m && m.length > 0
      case_id = m[0].gsub("case", "").gsub(":::", "").to_i
      c = Case.find(case_id)
    end
    
    # embedded code not found
    if c.nil?
      # Create new customer if needed
      cust = Customer.find_or_create_by(affiliate_id: q.affiliate_id, email: msg.from[0]) do |x|
        x.name = msg[:from].display_names.first || msg.from[0]
      end
      
      c = Case.find_or_create_by!(customer_id: cust.id, case_queue_id: q.id, status: [:new, :open]) do |x|
        x.status = :new
        assigned_to = q.initial_assignment
        name = msg[:from].display_names.first || msg.from[0],
        email = msg.from[0],
        subject = msg.subject,
        received_via = :email
      end
    end
    
    puts "CASE ID = #{c.id}"
    
    upd = CaseUpdate.create!(case_id: c.id,
                             received_at: msg.date,
                             received_via: :email,
                             raw_data: msg.header.raw_source,
                             response: desc )
    
    # Download attachments
    base_path = Setting.get(Rails.configuration.domain_id, :system, "Static Files Path")
    FileUtils.mkdir_p(base_path + "/attachments")
    
    msg.attachments.each do |attch|
      next if attch.body.blank?
      
      file_path = "/attachments/#{SecureRandom.uuid}." + attch.filename.split(".").last.downcase
      File.open(base_path + file_path, "w+b", 0644) { |f| f.write attch.body.decoded }

      upd.attachments.create(file_name: attch.filename,
                             file_size: attch.body.decoded.length,
                             content_type: attch.mime_type,
                             file_path: file_path)
    end
                
    user = User.find_by(email: msg.sender)   
    c.update_attribute(:user_id, user.id) unless user.nil?
    
    # mail.delete
    
    if c.updates.count > 1
      @logger.info "Case ##{c.id} received an update"
      CaseMailer.updated(c).deliver_later
    else
      @logger.info "Case ##{c.id} created"
      CaseMailer.assigned(c).deliver_later
    end
  end
	
	
  desc "Update older cases to save attachments in cms_attachments table"
  task extract_attachments: :environment do  
    @logger = Logger.new(STDOUT)
      
		base_path = Setting.get(Rails.configuration.domain_id, :system, "Static Files Path")
		FileUtils.mkdir_p(base_path + "/attachments")
		
    Case.all.each do |c|
			next if c.raw_data.blank?
			
			c.attachments.delete_all
			msg = Mail.new(c.raw_data)
			
	    msg.attachments.each do |attch|
	      next if attch.body.blank?
      
	      file_path = "/attachments/#{SecureRandom.uuid}." + attch.filename.split(".").last.downcase
	      File.open(base_path + file_path, "w+b", 0644) { |f| f.write attch.body.decoded }

	      c.attachments.build(file_name: attch.filename,
	                          file_size: attch.body.decoded.length,
	                          content_type: attch.mime_type,
	                          file_path: file_path)
	    end
			
			c.save!
		end
		
    CaseUpdate.all.each do |c|
			next if c.raw_data.blank?
			
			c.attachments.delete_all
			msg = Mail.new(c.raw_data)
			
	    msg.attachments.each do |attch|
	      next if attch.body.blank?
      
	      file_path = "/attachments/#{SecureRandom.uuid}." + attch.filename.split(".").last.downcase
	      File.open(base_path + file_path, "w+b", 0644) { |f| f.write attch.body.decoded }

	      c.attachments.build(file_name: attch.filename,
	                          file_size: attch.body.decoded.length,
	                          content_type: attch.mime_type,
	                          file_path: file_path)
	    end
			
			c.save!
		end
		
  end

end
