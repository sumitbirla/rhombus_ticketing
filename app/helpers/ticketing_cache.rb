module TicketingCache
  
  def self.open_tickets_count
    Rails.cache.fetch(:open_tickets_count, expires_in: 2.minutes) do 
      Case.where(status: ['new', 'open']).count
    end
  end
  
  def self.open_tickets_count_queue(queue_id)
    Rails.cache.fetch("tickets-queue-#{queue_id}", expires_in: 2.minutes) do 
      Case.where(case_queue_id: queue_id, status: ['new', 'open']).count
    end
  end
  
  def self.queue_list
    Rails.cache.fetch(:case_queue_list) do 
      CaseQueue.order(:name).all.load
    end
  end
  
end