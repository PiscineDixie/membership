# coding: utf-8
# Controller pour forcer le login de l'application
#
class LoginController < AdminController
  
  layout "membership"

  def login
    if request.post?
      user = User.authenticate(params[:userid], params[:password])
      if user.nil?
        flash[:notice] = "Nom d'usager ou mot de passe invalide."
      else
        session[:user] = user.id
        flash[:notice] = nil
        redirect_to :controller => 'familles'
      end
    end
    # Pour un "get" on continue et affiche le formulaire de login
  end
  
  def logout
    reset_session
    redirect_to :action => 'login'
  end
  
  # Creer un compte de super-user si rien n'existe
  def initialize
    super
    if !User.take
      aUser = User.new({:user_id => 'su', :roles => 'su'})
      aUser.save!
    end
  end

end
