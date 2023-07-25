# coding: utf-8
# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class AdminController < ApplicationController
    
    # Use the common layout for all controllers
    layout "membership"

    # l'application "admin" est toujours en francais
    around_action :set_locale
    def set_locale(&action)
      I18n.with_locale(:fr, &action)
    end
    
    def authenticate
      unless session[:user]
        redirect_to(root_url)
       end
    end
    
    def check_admin
      # Verifie que l'usager a le droit d'utiliser ce module
      unless session[:user] and User.hasAdminPriviledge(session[:user])
        flash[:notice] = "Vous n'avez pas le niveau de privilège suffisant pour ces opérations."
        redirect_to(root_url)
      end
    end
    
    def check_su
        # Verifie que l'usager a le droit d'utiliser ce module
      unless session[:user] and User.hasSuperUserPriviledge(session[:user])
        flash[:notice] = "Vous n'avez pas le niveau de privilège suffisant pour ces opérations."
        redirect_to(root_url)
      end
    end
    
end
