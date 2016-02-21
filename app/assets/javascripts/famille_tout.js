
var nouveauMembreId = 100;

/**
 * Fonction pour choisir une valeur de defaut pour l'ecusson en fonction de l'age
 * @param $membre le membre dont l'age vient de changer
 * @param age (int) nouvel age du membre
 */ 
function setEcusson($membre, age) {
  var $ecussonSel = $membre.find('.ecusson-sel');
  if (age < 8) {
    $ecussonSel[0].selectedIndex = 0;  /* debutant */
  }
  else if (age < 13) {
    $ecussonSel[0].selectedIndex = 1;  /* nageur */
  }
  else {
    $ecussonSel[0].selectedIndex = 2;  /* adulte */
    $membre.find('.acts-aide').show(400);
  }
}


/** Ajouter un membre. */
function ajouterMembreEH(event) {
  
  /* 
   * Ajouter un nouveau membre dans la section des membres et des participation
   * On vide les selections.
   */
  var $membre = $('#liste_membres .membre').first().clone();
  $('#liste_membres').append($membre);
  $membre.find('.prenom').val('').focus();
  $membre.find("input[type='checkbox']").prop('checked', false);
  $membre.find('input.id').remove();
  $membre.find('.LN_details, .acts-aide').hide();
  $membre.find('select.naissance').first().val(new Date().getFullYear() - 5);
  setEcusson($membre, 5);
  $membre.find('.membre-rem-btn').show();
  
  /* Remplacer le "name" attribute des inputs */
  nouveauMembreId = nouveauMembreId + 1;
  var newNamePrefix = 'famille[membres][' + nouveauMembreId + ']';
  var nameRe = /famille\[membres\]\[\d+\]/;
  $membre.find('input, select').each(function(ndx, elem) {
    var $elem =$(elem);
    var name = $elem.attr('name');
    var newName= name.replace(nameRe, newNamePrefix);
    $elem.attr('name', newName);
  });
  
  event.preventDefault();
}

/** Initialization */
$(document).ready(function() {
  
  if ($("#famille_tout").length === 1) {
    /* C'est l'edit d'une famille */
   
    /* Event handler pour calculer l'ecusson en fonction du changement d'annee de naissance */
    $("#liste_membres").on('change', '.naissance', function(event) {
      var $sel = $(this);
      if ($sel.attr("name").indexOf('year') > -1) {
        var age = this.length - this.selectedIndex - 1;
        setEcusson($sel.closest(".membre"), age);
      }
    });
   
    /* Handler pour le detail des cours de natation */
    $("#liste_membres").on('change', '.activite-LN', function(event) {
      var $sel = $(this);
      $sel.closest('.membre').find('.LN_details').toggle(400);
    });
    
    /* Handler pour le bouton pour enlever un membre */
    $("#liste_membres").on('click', '.membre-rem-btn', function(event) {
      $membre = $(this).closest('.membre');
      $membre.hide();
      $membre.find('.prenom').val('');
       
      if ($membre.find('input.id').length === 0) {
        $membre.remove();
      }
      event.preventDefault();
    });
  
    /* Handler pour le bouton pour ajouter un membre */
    $('#boutonAjouterMembre').click(ajouterMembreEH);
    
  }
});
