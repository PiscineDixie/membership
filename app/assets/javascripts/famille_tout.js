//
// Fonctions de base
//

function registerHandler(element, event, hdlr) {
  element.on(event, hdlr);
}


// Aller lire la langue: 0 - francais, 1 - anglais
function isEnglish()
{
  var langueElem = $("#famille_langue")[0];
  return langueElem.selectedIndex == 1;
}


//
// Fonctions pour empecher la navigation hors de la page sans sauver les changements
//
var changementEffectue = false

// Enregistrer qu'une modification a ete apporte
function onChangeEH(event) {
  changementEffectue = true;
  return true;
}

// Handler pour le bouton submit: Enleve le signal de changement
function onSubmitEH(event) {
  changementEffectue = false;
  return true;
}

function onBeforeUnloadEH(event) {
  if (changementEffectue) {
    if (isEnglish()) {
      return "You must select button 'Save' in panel 4 to save your changes.";
    } else {
      return "Vous devez faire le bouton 'Enregistrer' du panneau 4 pour préserver vos changements."
    }
  }
}

// Enregister l'event. Ceci est une fonction secondaire. S'il y a deja
// un handler pour un changment de valeur, nous conservons l'existant.
// Ceci est le cas pour le handler de setEcusson.
function initChangement() { 
  var elems = document.getElementsByTagName("input");
  for (var idx = 0; idx < elems.length; idx++) {
    var elem = elems[idx]
    if (elem.type == "submit") {
      $(elem).on("click", onSubmitEH);
    } else {
      $(elem).on("change", onChangeEH);
    }
  }
  
  elems = document.getElementsByTagName("select");
  for (var idx = 0; idx < elems.length; idx++) {
    var elem = elems[idx];
    $(elem).on("change", onChangeEH);
  }
  
  elems = document.getElementsByTagName("button");
  for (var idx = 0; idx < elems.length; idx++) {
    var elem = elems[idx];
    if (elem.type == "submit") {
      $(elem).on("change", onSubmitEH);
    }
  }
  
  
//  $("input,select").on("change", onChangeEH);
//  $(":submit").on("change click", onSubmitEH);
  window.onbeforeunload = onBeforeUnloadEH;
}



//
// Fonctions pour ajouter des membres dans le formulaire
//

// Helper function utilisee lors de l'addition d'un membre.
// Corrige les ids et les "name"s pour la form.
// Les "id" ont la forme: famille_membres_0_naissance_month
function corrigeMembreId(elem, oldId, newId) {
  // Mise a jour du id
  if (elem.id != "") {
    var id = new String(elem.id);
    if (id.indexOf(oldId) != -1) {
      elem.id = id.replace(oldId, newId).valueOf()
    }
  }
    
  // Mise a jour du "name" d'un input
	// Les "name" ont la forme: famille[membres][0][naissance][month]
  if (elem.tagName == "INPUT" || elem.tagName == "SELECT") {
    if (elem.name != "") {
      var oldName = "[" + oldId.substr(oldId.length - 1) + "]"
      var name = new String(elem.name);
      if (name.indexOf(oldName) != -1) {
        var newName = "[" + newId.substr(newId.length - 1) + "]"
        elem.name = name.replace(oldName, newName).valueOf()
      }
    }
  }
  
  // Recurse pour ses enfants
  var children = elem.childNodes;
  for (var i = 0; i < children.length; ++i) {
    corrigeMembreId(children[i], oldId, newId);
  }
}

// Construire la partition de l'implication communautaire
// On n'a pas a se preoccuper des noms enleves puisque ceci
// est une transaction en soi. Les deux cas a gerer:
//   - nouvelle famille donc l'entree existante ne contient pas de nom
//   - un nouveau nom est ajoute: une entree sans id avec prenom dans 'membres'
function construireParticipations() {
  
  // Trouve tous les noms (prenom + nom)
  var prenomNoms = new Array; // vecteur de paire<id, prenomNom>
  var listeMElem = $('#liste_membres')[0];
  for (var nextElem = listeMElem.firstChild; nextElem; nextElem = nextElem.nextSibling) {
    if (nextElem.className && nextElem.className == "membre") {
      var mId = nextElem.id.substr(8); // membres_<id>
      var nomElem = $("#famille_membres_" + mId + "_nom")[0]
      var prenomElem = $("#famille_membres_" + mId + "_prenom")[0]
      if (prenomElem.value.length > 0 && nomElem.value.length > 0) {
        prenomNoms.push(new Array(mId, prenomElem.value + " " + nomElem.value))
      }
    }
  }
  
  // Trouver le premier element de participations
  var listePElem = $('#liste_participations')[0];
  var firstElem = listePElem.firstChild;
  for (; firstElem; firstElem = firstElem.nextSibling) {
    if (firstElem.className && firstElem.className == "membre") {
      break;
    }
  }
  
  var firstNum = firstElem.id.substr(13); // part_membres_<id>
  
  // On reconstruit toute la liste
  var ajouteMembre = false;
  for (var idx = 0; idx < prenomNoms.length; idx++) {
    var num = prenomNoms[idx][0]
    var nom = prenomNoms[idx][1]

    // Voir si deja dans la table
    var elem = $("#part_nom_membres_" + num);
    if (elem.length) {
      elem[0].firstChild.nodeValue = nom;
      var divElem = $("#part_membres_" + num);
      if (divElem.length) {
        divElem[0].style.visibility = "visible"
      } else {
        alert("Could not retrieve division for " + nom + " " + num);
      }
      continue;
    }
    
    // Il n'existe pas encore, faire un clone du premier
    var newElem = firstElem.cloneNode(true);
    corrigeMembreId(newElem, "membres_" + firstNum, "membres_" + num)
    newElem.style.visibility = "visible";
    listePElem.appendChild(newElem);
    $("#part_nom_membres_" + num)[0].firstChild.nodeValue = nom;
    ajouteMembre = true;
  }
  
  // Je m'apprete a enlever les membres mais il ne faut pas tous les
  // enlever. Le dernier doit devenir invisible. Premierement les compter
  var numParts = 0;
  for (var elem = listePElem.firstChild; elem; elem = elem.nextSibling) {
    if (elem.className && elem.className == "membre") {
      numParts = numParts + 1
    }
  }
  
  // Il est possible que certains elements ne soient plus presents dans la liste de membres.
  // (On ajoute, on affiche participation, on revient enlever le membre, on affiche participations)
  // Parcourir la liste et enlever les items ayant un id non present
  for (var elem = listePElem.firstChild; elem; ) {
    if (elem.className && elem.className == "membre") {
      // Chercher ce membre dans la liste de prenomNoms
      var num = elem.id.substr(13); // part_membres_<id>
      trouve = false;
      for (var idx = 0; idx < prenomNoms.length; idx++) {
        var id = prenomNoms[idx][0]
        if (num == id) {
          trouve = true;
          break;
        }
      }
      
      if (!trouve) {
        numParts = numParts - 1;
        if (numParts == 0) {
          elem.style.visibility = "hidden";
          break;
        }
        else {
          var tmp = elem.nextSibling;
          listePElem.removeChild(elem);
          elem = tmp;
          continue;
        }
      }
    }
    elem = elem.nextSibling
  }
  
  // Re-active les changement pour tous les nouveaux elements
  if (ajouteMembre) {
    initChangement();
  }
}

// Activer la partition choisie
function setActivePartition(partId) {
  var parts = ["coordonnees", "membres", "participations", "autres"];
  if (partId == "participations")
    construireParticipations();
  for (var partIdx = 0; partIdx < 4; partIdx++) {
    var part = parts[partIdx]
    var divElem = $('#'+part)[0];
    var divCtrlElem = $("#sel_" + part)[0];
    if (part == partId) {
      divElem.style.display = 'block';
      divCtrlElem.className = 'selected';
    }
    else {
      divElem.style.display = 'none';
      divCtrlElem.className = 'unselected';
    }
  }
  return true;
}

// Event handler invoquer lorsqu'une partition est choisie
// Je retourne false pour eviter de suivre le lien (faux lien)
// Le "this" est un lien avec le "id" de la forme: sel_<partId> ou lnk_<partId>
function setActivePartitionEH(event) {
  if (!$(this).hasClass("selected")) {
    var partId = this.id.substr(4);
    setActivePartition(partId);
  }
  event.stopPropagation();
  return false
}

function initPartitions() {
  $("#sel_coordonnees").on("click", setActivePartitionEH);
  $("#sel_membres").on("click", setActivePartitionEH);
  $("#sel_participations").on("click", setActivePartitionEH);
  $("#sel_autres").on("click", setActivePartitionEH);

  $("#lnk_membres").on("click", setActivePartitionEH);
  $("#lnk_participations").on("click", setActivePartitionEH);
  $("#lnk_autres").on("click", setActivePartitionEH);
  
  setActivePartition("coordonnees")
} 

// Utilitaire pour trouver le nombre de membres dans le document
function numMembres(){
  var num = 0
  for (var n = $("#liste_membres")[0].firstChild; n != null; n = n.nextSibling) {
    if (n.className && n.className == 'membre') ++num
  }
  return num
}

// Trouver le prochain numero de id
function nextMembre(){
  var memId = ""
  for (var n = $("#liste_membres")[0].firstChild; n; n = n.nextSibling) {
    if (n.className && n.className == 'membre' && n.id > memId) memId = n.id;
  }
  return 1 + parseInt(memId.substr(8))
}


// Fonction pour activer les selections de cours de natation
function setLNVisibilityPourMembre(elem) {
  // Le "elem" est l'element checkbox des cours de natation
  // On extrait son membre id de son id: famille_membres_id_activites_LN
  var id = new String(elem.attr('id'))
  var memId = id.substr(16, 1)
  var detElem = $("#LN_details_membres_" + memId)
  if (elem.is(':checked'))
    detElem.show()
  else
    detElem.hide()
   
  return true;
}

// Event handler
function setLNVisibilityEH(event) {
  return setLNVisibilityPourMembre($(this));
}


// Fonction pour choisir une valeur de defaut pour l'ecusson en fonction de l'age
// Tout d'abord le handler
function setEcussonEH(event) {
  // Trouver le sibling qui a la class "ecusson"
  var age = this.length - this.selectedIndex - 1;
  var n = this.parentNode; // span de la date
  n = n.nextSibling;   // select de ecusson
  if (age < 8) {
    n.selectedIndex = 0;  // debutant
  }
  else if (age < 13) {
    n.selectedIndex = 1;  // nageur
  }
  else {
    n.selectedIndex = 2;  // senior
  }
  return true;
}


// Clear le prenom d'un membre pour l'enlever
function enleverMembreEH(event){
  // Verifier que ce n'est pas le dernier membre
  if (numMembres() < 2) {
    event.preventDefault();
    return;
  }
  
  // Enleve le prenom
  var id = new String(this.id);
  var memId = id.slice(id.indexOf("_")+1)
  var prenom = $("#famille_membres_" + memId + "_prenom")[0]
  prenom.value = ""
  
  // Si une personne deja dans la DB, retourne 'true' pour finir la transaction immediatement
  var dbId = $("#famille_membres_" + memId + "_id")[0]
  if (dbId.value > 0) return true;
  
  // Pas dans la DB. i.e. ajouter + enlever immediatement. On enleve de la table.
  // Retourne 'false' pour ne pas faire de transaction avec le serveur
  var divIdElem = $("#membres_" + memId)[0];
  var listIdElem = $("#liste_membres")[0];
  listIdElem.removeChild(divIdElem);

  event.preventDefault();
}


// Initializer les event handlers pour un membre
function initMembreEventHandlers(i) {
  // Estime de l'ecusson en fonction de l'age
  $("#famille_membres_" + i + "_naissance_year").on("change", setEcussonEH);
  
  // Activation des details des cours de natation
  var elem = $("#famille_membres_" + i + "_activites_LN");
  setLNVisibilityPourMembre(elem);
  elem.on("click", setLNVisibilityEH);
  
  // Handler pour enlever le prenom en enlever un membre
  $("#enlBouton_" + i).on("click", enleverMembreEH);
}

// Ajouter un membre.
function ajouterMembreEH(event) {
  // Trouver le nombre existant de membre
  var num = nextMembre();
  var membre;  // un des membre
  var membres = $("#liste_membres")[0];
  for (membre = membres.firstChild; membre; membre = membre.nextSibling) {
    if (membre.className && membre.className == "membre") {
      break;
    }
  }
  
  // Creer le nouveau membre a partir du premier
  var oldId = membre.id.substr(8)
  membre = membre.cloneNode(true);
  
  // Corriger les id des elements. Il faut remplacer les "_0_" par "_<num>"_
  corrigeMembreId(membre, "membres_" + oldId, "membres_" + num) // pour les champs
  corrigeMembreId(membre, "enlBouton_" + oldId, "enlBouton_" + num) // pour le bouton pour enlever un membre
  
  // Ajouter le nouvel element
  membres.appendChild(membre);
   
  // Enlever le prenom, le id et les activites
  $("#membres_" + num + "_rangee")[0].firstChild.nodeValue = "" + (num+1) + ".";
  $("#famille_membres_" + num + "_prenom")[0].value = ""
  $("#famille_membres_" + num + "_id")[0].value = ""
  var inputs = $("INPUT")
  for (var i = 0; i < inputs.length; ++i) {
    var input = inputs[i];
    var id = new String(input.attr('id'));
    if (id.indexOf("famille_membres_" + num + "_activites") != -1) {
      input.checked = false;
    }
  }
  
  initMembreEventHandlers(num);
  
  // Re-active les changement pour tous les nouveaux elements
  initChangement();
  
  return true;
}

// Initialized les event handlers pour tous les membres
function initMembresEventHandlers() {
  for (var i = 0; i < numMembres(); ++i) {
    initMembreEventHandlers(i)
  }
  $("#boutonAjouterMembre").on("click", ajouterMembreEH);
}


// Initialization
$(document).ready(function() {
  e = $("#famille_tout")
  if (e.length) {
    initPartitions();
    initMembresEventHandlers();
    initChangement();
  }
});
