# coding: utf-8
class FamilleMailer < ActionMailer::Base

  Tresorier = 'Piscine Dixie - Tresorier <tresorier@piscinedixiepool.com>'
  Abonnement = 'Piscine Dixie - Abonnements <abonnements@piscinedixiepool.com>'
  
  # Methode pour expedier un courriel avec les recus d'impot
  def recu(famille, recus, to, parent)
    headers basicHeaders(Abonnement, to)
    
    subject = famille.english? ? "Income tax receipt from Dixie Pool" : "Recus d'impot federal de Piscine Dixie"
    subject << (famille.english? ? ", Family: ": ", Famille: ") << famille.nom

    doc = Prawn::Document.new(:skip_page_creation => true, :compress => true)
    recus.each { |r| r.toPDF(doc, parent) }
    
    file = 'recus-dixie-' + recus[0].annee.to_s + '.pdf'
    attachments[file] = {
      :content_type => "application/pdf",
      :body         => doc.render
    }
    
    @famille = famille
    file = "recu_" + famille.langue.downcase + ".text"
    mail(:subject => subject, :template_name => file)
  end
  
  # Methode pour expedier un courriel d'information
  def info(famille, subject, to, msgOrig, lang, archiveIt = true)
    headers basicHeaders(Abonnement, to, archiveIt)
    
    # Si pas de tags HTML, on met dans un bloc <pre>
    msg = msgOrig
    msg = msg.gsub("\n", "<br/>\n") if msg[0,1] != '<'
      
    @famille = famille
    @msg = msg
    file = "info_" + langCode(lang) + ".text"
    mail(:subject => subject, :template_name => file)
  end
  
  # Methode pour expedier un courriel lors de l'abonnement
  def cotisation_notif(famille, to)
    headers basicHeaders(Abonnement, to)
    subject = famille.english? ? "Membership" : "Abonnement"

    @famille = famille
    file = "abonnement_" + famille.langue.downcase + ".text"
    mail(:subject => subject, :template_path => 'shared', :template_name => file)
  end
  
  # Methode pour expedier un courriel lors de la reception d'un paiement
  def paiement_notif(famille, paiement, to)
    headers basicHeaders(Abonnement, to)
    subject = famille.english? ? "Membership - payment received" : "Abonnement - reception d'un paiement"

    @famille = famille
    @paiement = paiement
    file = "paiement_notif_" + famille.langue.downcase + ".text"
    mail(:subject => subject, :template_name => file)
  end
  
  # Methode pour expedier un courriel lors de l'annulation du rabais de pre-inscription
  def rabais_notif(famille, to)
    headers basicHeaders(Abonnement, to)
    subject = famille.english? ? "Membership - end of pre-registration" : "Abonnement - fin de pre-inscription"

    @famille = famille
    file = "rabais_notif_" + famille.langue.downcase + ".text"
    mail(:subject => subject, :template_name => file)
  end
  
  # Informe le tresorier que la date d'un paiement fut modifiee
  def edit_paiement(famille, paiement, datePrecedente)
    headers basicHeaders(Abonnement, Tresorier)
    subject = "Modification d'un paiement"
    
    @famille = famille
    @paiement = paiement
    @dp = datePrecedente
    mail(:subject => subject, :template_name => 'edit_paiement_fr.text')
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
  
  def langCode(langue)
    case
      when langue == 'EN' || langue == 'FR' then return langue.downcase
      else return "ml"
    end
  end

end
