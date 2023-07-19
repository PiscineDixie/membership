# coding: utf-8
# Classe pour preparer une demande de rapports
#
class OperationsController < AdminController

  before_action :authenticate
  
  # La seule methode est "index". Elle affiche des "forms" qui
  # genere un URL pour le bon controller.
  def index
  end

end
