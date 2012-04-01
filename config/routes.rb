DiaX::Application.routes.draw do

  devise_for :users do
    get 'login', to: 'devise/sessions#new'
    post 'login', to: 'devise/sessions#create'
    get 'logout', to: 'devise/sessions#destroy'
    get 'signup', to: 'devise/registrations#new'
    get 'account', to: 'devise/registrations#edit'
  end

  get 'news' => 'faqs#show', id: 1
  get 'about' => 'faqs#show', id: 2

  resources :users, path: '/people'
  get 'users/add_name'
  put 'users/add_name_save'
  get 'users/show'
  
  root to: 'faqs#show', id: 1, as: :news
  match 'fen/(*id)' => 'fen#index'

  match 'authors/json'

  match 'collections/data'
  match 'collections/dbaction'

  get 'diagrams/mine'  
  get 'diagrams/section'  
  post 'diagrams/solve'
  
  match 'invites/accept/:code', controller: 'invites', action: 'react', accepted: true
  match 'invites/decline/:code', controller: 'invites', action: 'react', accepted: false

  match 'competitions/judge'

  resources :diagrams do
    member do
      put :section
      post :share
    end
  end
  resources :competitions, has_many: :sections
  resources :sections do
    member do
      get :judge
      post :mark
    end
  end

  resources :roles, :collections, :authors, :posts, :imports,
    :statuses, :faqs, :invites, :password_resets, :pieces
    
  match 'diagrams/section/:id' => 'diagrams#section'

  get ':id' => 'diagrams#show', constraints: {id: /\d\d\d\d\d+/}

end
