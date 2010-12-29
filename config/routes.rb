Shelltube::Application.routes.draw do

  resources :users
  resources :records
  resources :authentications

  match '/auth/:provider/callback' => 'authentications#create'
  match '/login',  :to => 'authentications#login',  :as => :login
  match '/logout', :to => 'authentications#logout', :as => :logout

  root :to => "records#index"

end
