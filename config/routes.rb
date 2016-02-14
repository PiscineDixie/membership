Membership::Application.routes.draw do
  # The priority is based upon order of creation:
  # first created -> highest priority.
  resources :constantes
  resources :users
  
  post 'auth/:provider/callback', to: 'sessions#create'
  match 'auth/failure', to: 'sessions#reject', via: [:post, :get]
  get 'signout', to: 'sessions#destroy', as: 'signout'
  
  # Les actions accessibles par le public pour editer leur profil familial
  # "public" est comme "famille" mais avec des fontions reduites et orientee "membres"
  get "public/login_fr" => 'public#login_fr'
  get "public/login_en" => 'public#login_en'
  match "public/login"    => 'public#login', via: [:get, :post]
  get "public/logout"   => 'public#logout'
  get "public/aide"     => 'public#aide'
  match "public/:id/recu" => 'public#recu', via: [:get, :post]
  get "public/:id/recupaiement" => 'public#recupaiement'
  resources :public

  # Les activites sportives offertes
  resources :activites do
    member do
      get "listeMembreNatation"
    end
    collection do
      post "listeMembre"
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
  get 'membres' => 'membres#index'
  post 'notes/rapport' => 'notes#rapport'
    
  get '/' => 'root#index'
  root to: 'root#index'
  
  get 'instructions' => 'root#instructions'

       
  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
