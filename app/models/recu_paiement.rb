# coding: utf-8
# J'utilise prawn pour generer le PDF. Il faut installer les packages:
#   yum install prawn

# Class qui represente un recu pour le paiement d'une famille
class RecuPaiement
    
  def initialize(f)
    @famille = f
  end
  
  # Add the recu as a page in the given document
  def toPDF()
    doc = Prawn::Document.new(:compress => true, :page_size => [500, 280])
    doc.font 'Times-Roman'
    
    # Les images pour le background, le logo, la signature du tresorier
    doc.image "public/images/recu.png", :at => [0, 200]
    doc.image "public/images/logo112x87.png", :at => [370, 195], :fit => [56, 44]
    doc.image "public/images/signature_recu.png", :at => [280, 80], :fit => [147,42]

    # Boite avec les informations principales du recu
    doc.bounding_box([5,180], :width => 500) do
      doc.text "Date: " + DateTime.now.strftime('%Y-%m-%d')
      
      doc.move_down 42
      annee = DateTime.now.strftime('%Y')
      doc.text "Reçu pour abonnement à la piscine Dixie " + annee, :style => :bold
      doc.text "Receipt for Dixie pool registration " + annee, :style => :bold
      
      doc.move_down 10
      doc.text "Nom/Name: " + nom
      doc.text "Montant perçu/Amount paid: " + sprintf('$%6.2f', @famille.paiementTotal)
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
    
    return doc
  end
  
  def nom
    if @famille.membres.size() == 1
      return @famille.membres[0].prenomNom
    else
      return @famille.nom
    end
  end
  
end
