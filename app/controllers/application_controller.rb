# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include AuthenticationHandling
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  # Filters added to this controller apply to all controllers in the application.
  # Likewise, all the methods added will be available for all controllers.

  helper_method :current_user_session, :current_user, :is_admin?, :may_edit?

  def may_edit?(o)
    return false unless current_user
    return is_admin? || (o.user.id == current_user.id)
  end

  def is_admin?
    return false unless current_user
    return ! current_user.roles.name_is('admin').empty?
  end

  private
    def current_user_session
      return @current_user_session if defined?(@current_user_session)
      @current_user_session = UserSession.find
    end

    def current_user
      return @current_user if defined?(@current_user)
      @current_user = current_user_session && current_user_session.record
    end

    def require_admin
      unless is_admin?
        store_location
        flash[:error] = "You may not do this."
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
      session[:return_to] = request.request_uri
    end

    def redirect_back_or_default(default)
      redirect_to(session[:return_to] || default)
      session[:return_to] = nil
    end

    def autovivifying_hash
      Hash.new {|ht,k| ht[k] = autovivifying_hash}
    end

end
