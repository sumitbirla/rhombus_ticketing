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

      Mail.find_and_delete(:what => :first, :count => 100, :order => :desc).each do |msg|
        
        puts msg.date.to_s + ": " + msg.from.to_s + " => " + msg.to.to_s + " => " + msg.attachments.length.to_s
        
        unless msg.multipart?
          desc = msg.body.decoded
        else     
          desc = msg.text_part.decoded
        end
        
        c = Case.new(case_queue_id: q.id,
                        priority: :normal,
                        status: :new,
                        assigned_to: q.initial_assignment,
                        attachments: msg.attachments.length,
                        name: msg[:from].display_names.first,
                        email: msg.from[0],
                        subject: msg.subject,
                        description: desc,
                        received_via: :email,
                        raw_data: msg.to_s)
        
        user = User.find_by(email: msg.sender)   
        c.user_id = user.id unless user.nil?
        
                     
        puts c.errors.inspect unless c.save
        
      end
    
    end
  end
  
end
