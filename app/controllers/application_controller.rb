# coding: utf-8
# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
    helper :all # include all helpers, all the time
    
    # See ActionController::RequestForgeryProtection for details
    protect_from_forgery
    
    # Use the common layout for all controllers
    layout "membership"
    
    def authenticate
        unless session[:user]
          redirect_to(root_url)
          return false
        end
        return true
    end
    
    def check_admin
        # Verifie que l'usager a le droit d'utiliser ce module
        unless session[:user] and User.hasAdminPriviledge(session[:user])
          flash[:error] = "Vous n'avez pas le niveau de privilège suffisant pour ces opérations."
          redirect_to(root_url)
          return false;
        end
        return true
    end
    
    def check_su
        # Verifie que l'usager a le droit d'utiliser ce module
        unless session[:user] and User.hasSuperUserPriviledge(session[:user])
          flash[:error] = "Vous n'avez pas le niveau de privilège suffisant pour ces opérations."
          redirect_to(root_url)
          return false;
        end
        return true
    end
    
end
