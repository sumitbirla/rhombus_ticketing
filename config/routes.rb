Rails.application.routes.draw do
  
  namespace :admin do
      
    namespace :ticketing do
      resources :case_queues
      resources :cases
    end
    
  end
  
end
