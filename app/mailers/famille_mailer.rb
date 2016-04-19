# coding: utf-8
class FamilleMailer < ActionMailer::Base

  Tresorier = 'Piscine Dixie - Tresorier <tresorier@piscinedixiepool.com>'
  Abonnement = 'Piscine Dixie - Abonnements <abonnements@piscinedixiepool.com>'
  
  # Methode pour expedier un courriel avec les recus d'impot
  def recu(famille, recus, to, parent)
    headers basicHeaders(Abonnement, to)
    
    subject = default_i18n_subject(nom: famille.nom)

    l = I18n.locale
    I18n.locale= famille.langue.downcase
    
    doc = Prawn::Document.new(:skip_page_creation => true, :compress => true)
    recus.each { |r| r.toPDF(doc, parent) }
    
    file = 'recus-dixie-' + recus[0].annee.to_s + '.pdf'
    attachments[file] = {
      :content_type => "application/pdf",
      :body         => doc.render
    }
    
    @famille = famille
    mail(:subject => subject, :template_name => "recu")
    
    I18n.locale = l
  end
  
  # Methode pour expedier un courriel d'information
  def info(famille, subject, to, msgOrig, lang, archiveIt = true)
    headers basicHeaders(Abonnement, to, archiveIt)
    
    # Si pas de tags HTML, on met dans un bloc <pre>
    msg = msgOrig
    msg = msg.gsub("\n", "<br/>\n") if msg[0,1] != '<'
      
    @famille = famille
    @msg = msg
    l = I18n.locale
    I18n.locale= lang.downcase
    mail(:subject => subject, :template_name => "info")
    
    I18n.locale = l
  end
  
  # Methode pour expedier un courriel lors de l'abonnement
  def cotisation_notif(famille, to)
    headers basicHeaders(Abonnement, to)
    subject = famille.english? ? "Membership" : "Abonnement"

    l = I18n.locale
    I18n.locale= famille.langue.downcase
    
    @famille = famille
    mail(:subject => subject, :template_path => 'shared', :template_name => "_abonnement")
    
    I18n.locale = l
  end
  
  # Methode pour expedier un courriel lors de la reception d'un paiement
  def paiement_notif(famille, paiement, to)
    headers basicHeaders(Abonnement, to)
    subject = famille.english? ? "Membership - payment received" : "Abonnement - reception d'un paiement"

    l = I18n.locale
    I18n.locale= famille.langue.downcase
    
    @famille = famille
    @paiement = paiement
    mail(:subject => subject, :template_name => "paiement_notif")
    
    I18n.locale = l
  end
  
  # Methode pour expedier un courriel lors de l'annulation du rabais de pre-inscription
  def rabais_notif(famille, to)
    headers basicHeaders(Abonnement, to)
    subject = famille.english? ? "Membership - end of pre-registration" : "Abonnement - fin de pre-inscription"

    l = I18n.locale
    I18n.locale= famille.langue.downcase
    
    @famille = famille
    mail(:subject => subject, :template_name => "rabais_notif")
    
    I18n.locale = l
  end
  
  # Informe le tresorier que la date d'un paiement fut modifiee
  def edit_paiement(famille, paiement, datePrecedente)
    headers basicHeaders(Abonnement, Tresorier)
    subject = "Modification d'un paiement"
    
    @famille = famille
    @paiement = paiement
    @dp = datePrecedente
    mail(:subject => subject, :template_name => 'edit_paiement')
  end
  
 
private
  def basicHeaders(from, to, archiveIt = true)
    h = {
      :to => to,
      :from => from,
      :reply_to => from
    }
    h[:bcc] = 'archives@piscinedixiepool.com' if archiveIt
    h
  end
  
end
