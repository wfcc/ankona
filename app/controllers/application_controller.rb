# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base

  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  
  before_filter :user_has_name, except: [:add_name, :destroy, :json, :add_name_save ]
  before_filter :c_user

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  # Filters added to this controller apply to all controllers in the application.
  # Likewise, all the methods added will be available for all controllers.

  helper_method :current_user_session, :current_user, 
    :is_admin?, :may_edit?, :has_role?, :is_director?
  #before_filter :check_geo
  
  rescue_from CanCan::AccessDenied do |exception|
    Rails.logger.debug "Access denied on #{exception.action} #{exception.subject.inspect}"
    redirect_to root_url, :alert => exception.message
  end

  rescue_from ActiveRecord::RecordNotFound do |exception|
    flash[:alert] = 'The object you tried to access does not exist. Check the address.'
    #render :not_found   # or e.g. redirect_to :action => :index
    redirect_to '/', :alert => exception.message
  end

#  rescue_from ActiveRecord::RecordNotFound do |exception|
#    Rails.logger.debug "RecordNotFound on #{exception.inspect}"
#    redirect_to root_url, alert: 'There is no such thing.'
#  end

#  rescue_from ActionController::RoutingError do |exception|
#    redirect_to root_url, alert: 'You have requested something that we don''t have.'
#  end

  def c_user
    User.current_user = current_user
  end

  def user_has_name
    if current_user and current_user.author.blank?
      flash[:notice] = "Provide your real name to complete your registration."
      redirect_to '/users/add_name'
      return false
    end
  end
    
    
  def check_geo
    if session[:geo].blank?   
      c = GeoIP.new(Settings.geoipdat).country(request.remote_ip)[3]
      session[:geo] = {value: c, expires: Time.now + 36000}
    end
  end


  def may_edit?(o)
    return false unless current_user
    return is_admin? || (o.user.id == current_user.id)
  end

#  def has_role?(role)
#    return false unless current_user
#    return current_user.roles.where(name: role.to_s).exists?
#  end

  def is_admin?
    return false unless current_user
    return current_user.roles.where(:name => 'admin').exists?
  end

  def is_director?
    return false unless current_user
    return current_user.roles.where(:name => 'director').exists?
  end

  private

    def require_admin
      unless is_admin?
        flash[:error] = "You may not do this."
        redirect_to '/login'
        return false
      end
    end

    def require_director
      unless is_director?
        flash[:error] = "You may not do this."
        redirect_to '/'
        return false
      end
    end

    def require_user
      unless current_user
        store_location
        flash[:error] = "You must be logged in to access this page."
        redirect_to '/login'
        #redirect_to new_user_session_url
#        redirect_to url_for, :controller => :user_sessions, :action => :new
        return false
      end
    end

    def require_no_user
      if current_user
        store_location
        flash[:error] = "You must be logged out to access this page."
        redirect_to account_url
        return false
      end
    end

    def store_location
      session[:return_to] = request.fullpath
    end

    def redirect_back_or_default(default)
      redirect_to(session[:return_to] || default)
      session[:return_to] = nil
    end

    #def autovivifying_hash
    #  Hash.new {|ht,k| ht[k] = autovivifying_hash}
    #end

end
