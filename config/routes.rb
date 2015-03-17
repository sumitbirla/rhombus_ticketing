Rails.application.routes.draw do
  
  namespace :account do
    resources :cases
  end
  
  
  namespace :admin do
      
    namespace :ticketing do
      resources :case_queues
      resources :cases do
        member do 
          get "raw_data"
          get "attachment"
        end
      end
      resources :case_updates
      
    end
    
  end
  
end
