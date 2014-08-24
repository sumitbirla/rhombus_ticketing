Rails.application.routes.draw do
  
  namespace :account do
    resources :cases
  end
  
  
  namespace :admin do
      
    namespace :ticketing do
      resources :case_queues
      resources :cases
    end
    
  end
  
end
