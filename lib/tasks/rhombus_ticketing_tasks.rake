# desc "Explaining what the task does"
# task :rhombus_ticketing do
#   # Task goes here
# end

require 'mail'

namespace :rhombus_ticketing do
  
  desc "TODO"
  task process_inbox: :environment do
    
    CaseQueue.where(pop3_enabled: true).each do |q|
    
    	Mail.defaults do
        retriever_method :pop3, { :address    => q.pop3_host,
                                  :port       => q.pop3_port,
                                  :user_name  => q.pop3_login,
                                  :password   => q.pop3_password,
                                  :enable_ssl => q.pop3_use_ssl }
    	end

      Mail.all.each do |mail|
        
        puts mail.date.to_s + ": " + mail.from.to_s + " => " + mail.to.to_s + " => " + mail.attachments.length.to_s
        
        unless mail.multipart?
          desc = mail.body.decoded
        else     
          desc = mail.text_part.decoded
        end
        
        c = Case.new(case_queue_id: q.id,
                        priority: :normal,
                        status: :new,
                        assigned_to: q.initial_assignment,
                        attachments: mail.attachments.length,
                        name: mail[:from].display_names.first,
                        email: mail.from[0],
                        subject: mail.subject,
                        description: desc,
                        received_via: :email,
                        raw_data: mail.to_s)
        
        user = User.find_by(email: mail.sender)   
        c.user_id = user.id unless user.nil?
        
                     
        puts c.errors.inspect unless c.save
        
      end
    
    end
  end
  
end
