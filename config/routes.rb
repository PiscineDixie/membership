Rails.application.routes.draw do
  # The priority is based upon order of creation:
  # first created -> highest priority.
  resources :constantes
  resources :users
  resources :produits
  
  resources :commandes do
    member do
      post "etat" # changer l'etat d'une commande
    end
  end
  
  get 'login', to: 'sessions#create', as: :create_login
  get 'signout', to: 'sessions#destroy', as: 'signout'
  
  # Les actions accessibles par le public pour editer leur profil familial
  # "public" est comme "famille" mais avec des fontions reduites et orientee "membres"
  get "public/", to: "public#home", as: "public/"
  get "public/home", to: "public#home", as: "public/home"
  get "public/login_fr" => 'public#login_fr'
  get "public/login_en" => 'public#login_en'
  match "public/login"    => 'public#login', via: [:get, :post]
  get "public/logout"   => 'public#logout'
  get "public/aide"     => 'public#aide'
  get "public/payer"     => 'public#payer'
  match "public/:id/recu" => 'public#recu', via: [:get, :post]
  get "public/:id/recupaiement" => 'public#recupaiement'
  get "public/courriels_bloques" => 'public#courriels_bloques'
  resources :public


  # Panier d'achats
  get "paniers/:id/show", to: 'paniers#show', as: 'paniers/show'
  post "paniers/:id/plus", to: 'paniers#add_item', as: 'paniers/plus'
  post "paniers/:id/checkout", to: 'paniers#checkout', as: 'paniers/checkout'
  post "paniers/:id/acheter", to: 'paniers#acheter', as: 'paniers/acheter'
  post "paniers/:id/annuler", to: 'paniers#cancel', as: 'paniers/cancel'
  
  # Les activites sportives offertes
  resources :activites do
    member do
      get "listeMembreNatation"
    end
    collection do
      post "listeMembre"
      get "sommaire"
    end
  end
  
  # Les activites communautaires      
  resources :participations do
    collection do
      post "listeMembre"
    end
  end
        
  # Les operations sur les familles.
  resources :familles do
    resource :cotisation do
      get 'calcul'             # Calcul de la cotisation
    end
    resources :membres, :paiements, :notes
    member do
      get 'recu'               # Rapport d'impot pour une seule famille
      post 'desactive'           # Mettre inactive la famille
      post 'ecussonsRemis'     # enregistrer que les ecussons sont remis
    end
    collection do
      post 'courriel'          # Expédier un courriel
      get 'courriel'           # Formulaire pour un courriel aux familles
      get 'stats'              # Statistiques du nombre de familles, etc.
      get 'cotisations'        # Rapport des cotisations pour toutes les familles
      get 'pas_courriels'      # Rapport des familles sans adresses courriel
      get 'inactifs'           # Rapport des familles inactives
      get 'ecussons'           # Rapport des ecussons a remettre aux familles
      get 'dues'               # Rapport des cotisation dues
      post 'debutAnnee'        # Remise a zero pour le debut de l'annee
      post 'recus'             # Production des recues pour credit d'impot federal
      post 'exp_recus'         # Envoi des recues pour credit d'impot federal
      post 'annulerRabais'     # Annuler les rabais de pre-inscription
      post 'recherche'         # Recherche d'une famille
    end
  end
        
  get 'rapports' => 'rapports#index'
  get 'operations' => 'operations#index'
  post 'paiements/revenus' => 'paiements#revenus'
  post 'paiements/depots' => 'paiements#depots'
  get 'membres/seniors' => 'membres#seniors'
  get 'membres/sommaire' => 'membres#sommaire' # rapport groupé par code postal
  get 'membres' => 'membres#index'
  post 'notes/rapport' => 'notes#rapport'
    
  get '/' => 'root#index'
  root to: 'root#index'
  
  get 'instructions' => 'root#instructions'
end
