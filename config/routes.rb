Shelr::Application.routes.draw do

  resources :records do
    resources :comments

    get :search, :on => :collection
  end

  resources :users do
    get :authenticate, :on => :collection
  end

  match '/auth/:provider/callback' => 'users#authenticate'

  match '/logout' => 'users#logout', as: 'logout'
  match '/login'  => 'users#login', as: 'login'
  match '/about'  => 'home#about', as: 'about'

  root :to => "home#landing"

end
