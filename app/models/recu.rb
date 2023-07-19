# coding: utf-8
# J'utilise prawn pour generer le PDF. Il faut installer les packages:
#   yum install prawn

# Class qui represente un recu pour l'impot
class Recu < ApplicationRecord
  
  belongs_to :famille, inverse_of: :recus
  
  # Add the recu as a page in the given document
  def toPDF(doc, parent)
    if !parent
      raise "Pas de parent pour le recu"
    end
    
    doc.start_new_page
    doc.font 'Times-Roman'
    
    # On fait deux copies.
    [650, 400].each do |y|
      doc.bounding_box([0, y], :width => 500, :height => 200) do
        oneRecu(doc, parent)
      end
    end
    
  end
  
  def oneRecu(doc, parent)
    # Les images pour le background, le logo, la signature du tresorier
    doc.image "public/images/recus/recu.png", :at => [0, 200]
    doc.image "public/images/recus/logo112x87.png", :at => [370, 195], :fit => [56, 44]
    doc.image "public/images/recus/signature_recu.png", :at => [280, 80], :fit => [147,42]

    # Boite avec les informations principales du recu
    doc.bounding_box([5,180], :width => 500) do
      doc.text "Date: " + DateTime.now.strftime('%Y-%m-%d')
      
      doc.move_down 22
      doc.text "Reçu pour le programme Dixie d'activités nautiques " + self.annee.to_s, :style => :bold
      doc.text "Receipt for the " + self.annee.to_s + " Dixie Water Activities Program", :style => :bold
      
      doc.move_down 10
      doc.text "Nom/Name: " + parent
      doc.text "Enfant/Child: " + self.prenom + ' ' + self.nom
      doc.text "Date de naissance/Date of birth: " + self.naissance.to_formatted_s(:db)
      doc.text "Montant reçu/Total amount: " + sprintf('$%6.2f', self.montant)
      doc.text "Montant éligible/Deductible amount: " + sprintf('$%6.2f', self.montant)
      doc.text "Date d'inscription/Date received: " + self.montant_recu.to_formatted_s(:db)
    end
    
    # Boite avec les coordonnes de la piscine. En haut a droite avec le logo dedans
    doc.bounding_box([220, 195], :width => 210, :height => 45) do
      doc.stroke_bounds
      doc.bounding_box([2, 43], :width => 210) do
        doc.text "Association Piscine Dixie Inc."
        doc.text "CP 34045"
        doc.text "Lachine, Qc, H8S 4H4"
      end
    end
    
    # Sous la signature
    doc.draw_text "Trésorier / Treasurer", :at => [300, 30]
  end
  
end
