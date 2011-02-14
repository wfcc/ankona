DiaX::Application.routes.draw do

  match "/stylesheets/:package.css" => AssetsApp.action(:stylesheets), as: 'stylesheets'

  root to: 'faqs#show', id: 1
  match 'fen/(*id)' => 'fen#index'

  match 'authors/json' => 'authors#json'

  match 'collections/data' => 'collections#data'
  match 'collections/dbaction' => 'collections#dbaction'

  match 'diagrams/mine' => 'diagrams#mine'  
  match 'diagrams/section' => 'diagrams#section'  
  
  resources :statuses

  resources :faqs

  resources :invites
  match 'invites/accept/:code', controller: 'invites', action: 'react', accepted: true
  match 'invites/decline/:code', :controller => 'invites', :action => 'react', :accepted => false


  match 'competitions/judge' => 'competitions#judge'

  resources :competitions, has_many: :sections

  resources :roles
  resources :collections
  resources :authors
  resources :posts
  resources :diagrams #, :active_scaffold => true
  match 'diagrams/solve/:id' => 'diagrams#solve'
  match 'diagrams/section/:id' => 'diagrams#section'

  #connect 'fen/*id', :controller => 'fen'

  match 'signup', to: 'users#create', via: :post
  match 'signup', to: 'users#new', via: :get
  resource :account, :controller => 'users'
  resources :password_resets

  match 'login', to: 'user_sessions#create', via: :post
  match 'login', to: 'user_sessions#new', via: :get
  match 'logout', to: 'user_sessions#destroy'
  
  resources :imports

end
