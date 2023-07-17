# coding: utf-8
class ConstantesController < ApplicationController

  before_action :check_su, :only => :update
  before_action :authenticate, :except => :update
  

  # GET /constantes/1
  def show
    @constantes = Constantes.instance
  end

  # GET /constantes/1/edit
  def edit
    @constantes = Constantes.instance
  end

  # PUT /constantes/1
  def update
    if (params[:cancel])
      redirect_to(constante_path)
      return;
    end
    
    @constantes = Constantes.instance
    if @constantes.update(params[:constantes].permit!)
      flash[:notice] = 'Constantes was successfully updated.'
      redirect_to constante_path
    else
      render :action => "edit"
    end
  end

end
