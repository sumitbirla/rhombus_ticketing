Rails.application.routes.draw do
  
  resources :cases
  
  namespace :account do
    resources :cases
  end
  
  namespace :admin do
      
    namespace :ticketing do
      
      post "cases_update_status" => "cases#update_status" 
      post "cases_delete_batch" => "cases#delete_batch"
      
      resources :case_queues
      resources :cases do
        member do 
          get "raw_data"
          get "attachment"
        end
      end
      resources :case_updates do 
        member do 
          get "raw_data"
          get "attachment"
        end
      end
      
    end
    
  end
  
end
