require File.expand_path(File.dirname(__FILE__) + "/lib/insert_routes.rb")

class AuthlogicGenerator < Rails::Generator::Base
                  
  def manifest
    record do |m|
      
      # COPY FILES
      # app/controllers
      m.file('app/controllers/user_sessions_controller.rb', 'app/controllers/user_sessions_controller.rb')
      m.file('app/controllers/users_controller.rb', 'app/controllers/users_controller.rb')      

      # app/models
      m.file('app/models/user_session.rb', 'app/models/user_session.rb')
      m.file('app/models/user.rb', 'app/models/user.rb')      

      # app/views
      m.directory('app/views/user_sessions')
      m.file('app/views/user_sessions/new.html.erb', 'app/views/user_sessions/new.html.erb')
      m.directory('app/views/users')
      m.file('app/views/users/_form.html.erb', 'app/views/users/_form.html.erb')      
      m.file('app/views/users/edit.html.erb', 'app/views/users/edit.html.erb')      
      m.file('app/views/users/new.html.erb', 'app/views/users/new.html.erb')      
      m.file('app/views/users/show.html.erb', 'app/views/users/show.html.erb')                    

      # lib
      m.file('lib/authentication_handling.rb', 'lib/authentication_handling.rb')

      # test/fixtures
      m.file('test/fixtures/users.yml', 'test/fixtures/users.yml')

      # test/functional
      m.file('test/functional/user_sessions_controller_test.rb', 'test/functional/user_sessions_controller_test.rb')
      m.file('test/functional/users_controller_test.rb', 'test/functional/users_controller_test.rb')      

      # test/unit
      m.file('test/unit/user_session_test.rb', 'test/unit/user_session_test.rb')
      m.file('test/unit/user_test.rb', 'test/unit/user_test.rb')      
      
      
      # Include authentication handling module in application controller
      m.edit_file('/app/controllers/application_controller.rb', 'class ApplicationController < ActionController::Base', 'include AuthenticationHandling')
      
      
      # CREATE ROUTES    
      # user sessions
      m.route_name('logout', '/logout', { :controller => "user_sessions", :action => 'destroy' } )
      m.route_name('login', '/login', { :controller => "user_sessions", :action => 'new', :conditions => { :method => :get }} )
      m.route_name('login', '/login', { :controller => "user_sessions", :action => 'create', :conditions => { :method => :post }})

      # user
      m.route_resource('account', :controller => "users")
      m.route_name('signup', '/signup', {:controller => "users", :action => "new", :conditions => { :method => :get }})
      m.route_name('signup', '/signup', {:controller => "users", :action => "create", :conditions => { :method => :post }})        
      
      
      
      # CREATE DATABASE MIGRATIONS
      m.migration_template "db/migrate/create_users.rb", "db/migrate", :migration_file_name => 'create_users'
      
      # Show Readme
      m.readme "../INSTALL"
    end
  end
      
end