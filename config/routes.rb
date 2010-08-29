ActionController::Routing::Routes.draw do |map|
  
  root to: 'faqs#show', id: 1
  match 'fen/(*id)' => 'fen#index'

  match 'collections/data' => 'collections#data'
  match 'collections/dbaction' => 'collections#dbaction'
  
  map.resources :statuses

  map.resources :faqs

  map.resources :invites
  map.connect 'invites/accept/:code', :controller => 'invites', :action => 'react', :accepted => true
  map.connect 'invites/decline/:code', :controller => 'invites', :action => 'react', :accepted => false


  map.connect 'competitions/judge', :controller => 'competitions', :action => 'judge'

  map.resources :competitions

  map.resources :roles
  map.resources :collections
  map.resources :authors
  map.resources :posts
  map.resources :diagrams #, :active_scaffold => true
  map.connect 'diagrams/solve/:id', :controller => 'diagrams', :action => 'solve'
  map.connect 'diagrams/section/:id', :controller => 'diagrams', :action => 'section'

  #map.connect 'fen/*id', :controller => 'fen'

  map.signup '/signup', :controller => 'users', :action => 'create', :conditions => { :method => :post}
  map.signup '/signup', :controller => 'users', :action => 'new', :conditions => { :method => :get}
  map.resource :account, :controller => 'users'
  map.resources :password_resets

  map.login '/login',   :controller => 'user_sessions', :action => 'create', :conditions => { :method => :post}
  map.login '/login',   :controller => 'user_sessions', :action => 'new', :conditions => { :method => :get}
  map.logout '/logout', :controller => 'user_sessions', :action => 'destroy'

  map.resources :imports

#  map.root :controller => 'faqs', :action => 'show', :id => 1


end
