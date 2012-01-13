Shelr::Application.routes.draw do

  resources :records
  resources :users do
    get :authenticate
  end

  match '/auth/:provider/callback' => 'users#authenticate'

  match '/logout' => 'users#logout', as: 'logout'
  match '/login'  => 'users#login', as: 'login'

  root :to => "records#index"

end
