DiaX::Application.routes.draw do

  #root :to => 'controller#index', :constraints => lambda{|req| !req.session[:user_id].blank?}
  #match '/' => 'faqs#shield', :constraints => lambda{|req| req.host == 'localhosta'}
  #match '/:x' => 'faqs#shield', 
  #  :constraints => lambda { |req|
  #    (controller.controller_name != 'faqs') and req.host == 'localhost'
  #  }

  devise_for :users do
    get 'login', to: 'devise/sessions#new'
    post 'login', to: 'devise/sessions#create'
    get 'logout', to: 'devise/sessions#destroy'
    get 'signup', to: 'devise/registrations#new'
    get 'account', to: 'devise/registrations#edit'
  end

  resources :users, path: '/people'
  get 'users/add_name'
  put 'users/add_name_save'
  get 'users/show'
  
  root to: 'faqs#show', id: 1
  match 'fen/(*id)' => 'fen#index'

  match 'authors/json' => 'authors#json'

  match 'collections/data' => 'collections#data'
  match 'collections/dbaction' => 'collections#dbaction'

  get 'diagrams/mine'  
  get 'diagrams/section'  
  post 'diagrams/solve'
  
  match 'invites/accept/:code', controller: 'invites', action: 'react', accepted: true
  match 'invites/decline/:code', controller: 'invites', action: 'react', accepted: false

  match 'competitions/judge' => 'competitions#judge'

  resources :diagrams do
    member do
      put :section
      post :share
    end
  end
  resources :competitions, has_many: :sections
  resources :sections do
    member {get :judge}
    member {post :mark}
  end

  resources :roles, :collections, :authors, :posts, :imports,
    :statuses, :faqs, :invites, :password_resets, :pieces
    
  match 'diagrams/section/:id' => 'diagrams#section'

end
