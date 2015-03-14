module TicketingCache
  
  def self.open_tickets_count
    Rails.cache.fetch(:open_tickets_count, expires_in: 2.minutes) do 
      Case.where(status: ['new', 'open']).count
    end
  end
  
end