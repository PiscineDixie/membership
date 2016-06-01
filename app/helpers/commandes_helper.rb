module CommandesHelper
  def t_etat(etat)
    return t("activerecord.attributes.commande.etat." + etat)
  end
end
