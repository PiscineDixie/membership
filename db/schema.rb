# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 21) do

  create_table "activites", :force => true do |t|
    t.string   "code",                                                          :null => false
    t.string   "description_fr",                                                :null => false
    t.string   "description_en",                                                :null => false
    t.string   "url_fr"
    t.string   "url_en"
    t.boolean  "gratuite"
    t.decimal  "cout",           :precision => 8, :scale => 2, :default => 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "activites", ["code"], :name => "par_code", :unique => true

  create_table "activites_membres", :id => false, :force => true do |t|
    t.integer "activite_id"
    t.integer "membre_id"
  end

  add_index "activites_membres", ["membre_id"], :name => "par_membre"
  add_index "activites_membres", ["activite_id"], :name => "par_activite"

  create_table "constantes", :force => true do |t|
    t.decimal  "baseSenior",                   :precision => 8, :scale => 2, :default => 0.0
    t.decimal  "baseIndividu",                 :precision => 8, :scale => 2, :default => 0.0
    t.decimal  "baseFamille",                  :precision => 8, :scale => 2, :default => 0.0
    t.decimal  "activiteSenior",               :precision => 8, :scale => 2, :default => 0.0
    t.decimal  "activiteIndividu",             :precision => 8, :scale => 2, :default => 0.0
    t.decimal  "activiteFamille",              :precision => 8, :scale => 2, :default => 0.0
    t.decimal  "rabaisPreInscriptionSenior",   :precision => 8, :scale => 2, :default => 0.0
    t.decimal  "rabaisPreInscriptionIndividu", :precision => 8, :scale => 2, :default => 0.0
    t.decimal  "rabaisPreInscriptionFamille",  :precision => 8, :scale => 2, :default => 0.0
    t.date     "finPreInscription"
    t.string   "codeLeconNatation"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "cout_billet",                  :precision => 8, :scale => 2, :default => 0.0
  end

  create_table "cotisations", :force => true do |t|
    t.integer  "famille_id"
    t.decimal  "cotisation_calculee",   :precision => 8, :scale => 2, :default => 0.0
    t.decimal  "cotisation_exemption",  :precision => 8, :scale => 2, :default => 0.0
    t.decimal  "non_taxable",           :precision => 8, :scale => 2, :default => 0.0
    t.boolean  "familiale"
    t.decimal  "frais1",                :precision => 8, :scale => 2, :default => 0.0
    t.string   "frais1_explication",                                  :default => ""
    t.decimal  "frais2",                :precision => 8, :scale => 2, :default => 0.0
    t.string   "frais2_explication",                                  :default => ""
    t.decimal  "frais3",                :precision => 8, :scale => 2, :default => 0.0
    t.string   "frais3_explication",                                  :default => ""
    t.decimal  "frais4",                :precision => 8, :scale => 2, :default => 0.0
    t.string   "frais4_explication",                                  :default => ""
    t.decimal  "frais5",                :precision => 8, :scale => 2, :default => 0.0
    t.string   "frais5_explication",                                  :default => ""
    t.decimal  "frais6",                :precision => 8, :scale => 2, :default => 0.0
    t.string   "frais6_explication",                                  :default => ""
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "rabais_preinscription", :precision => 8, :scale => 2, :default => 0.0
    t.integer  "nombre_billets",                                      :default => 0
    t.decimal  "cout_billets",          :precision => 8, :scale => 2, :default => 0.0
    t.decimal  "frais_supplementaires", :precision => 8, :scale => 2, :default => 0.0
  end

  add_index "cotisations", ["famille_id"], :name => "par_famille", :unique => true

  create_table "familles", :force => true do |t|
    t.string   "adresse1"
    t.string   "adresse2"
    t.string   "ville"
    t.string   "province",    :limit => 2
    t.string   "code_postal", :limit => 6
    t.string   "tel_soir",    :limit => 20
    t.string   "tel_jour",    :limit => 20
    t.string   "courriel1"
    t.string   "courriel2"
    t.string   "langue"
    t.string   "etat"
    t.string   "code_acces",                :default => ""
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "familles", ["code_acces"], :name => "par_code_acces", :unique => true

  create_table "membres", :force => true do |t|
    t.integer  "famille_id"
    t.string   "nom",                                 :null => false
    t.string   "prenom",                              :null => false
    t.date     "naissance",                           :null => false
    t.string   "ecusson",                             :null => false
    t.string   "cours_de_natation",   :default => ""
    t.string   "session_de_natation", :default => ""
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "membres", ["famille_id"], :name => "par_famille"

  create_table "notes", :force => true do |t|
    t.integer  "famille_id"
    t.date     "date"
    t.string   "auteur"
    t.text     "info"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "notes", ["famille_id"], :name => "par_famille"

  create_table "paiements", :force => true do |t|
    t.integer  "famille_id"
    t.date     "date"
    t.decimal  "montant",     :precision => 8, :scale => 2, :default => 0.0
    t.decimal  "non_taxable", :precision => 8, :scale => 2, :default => 0.0
    t.decimal  "taxable",     :precision => 8, :scale => 2, :default => 0.0
    t.decimal  "tps",         :precision => 8, :scale => 2, :default => 0.0
    t.decimal  "tvq",         :precision => 8, :scale => 2, :default => 0.0
    t.string   "note"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "paiements", ["famille_id"], :name => "par_famille"

  create_table "participations", :force => true do |t|
    t.string   "description_fr", :null => false
    t.string   "description_en", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "participations_membres", :id => false, :force => true do |t|
    t.integer "participation_id"
    t.integer "membre_id"
  end

  add_index "participations_membres", ["membre_id"], :name => "par_membre"
  add_index "participations_membres", ["participation_id"], :name => "par_participation"

  create_table "recus", :force => true do |t|
    t.integer "famille_id"
    t.integer "annee"
    t.string  "info"
    t.string  "prenom"
    t.string  "nom"
    t.date    "naissance",                                                   :null => false
    t.decimal "montant",      :precision => 8, :scale => 2, :default => 0.0
    t.date    "montant_recu"
  end

  add_index "recus", ["famille_id", "annee"], :name => "par_famille_annee"

  create_table "users", :force => true do |t|
    t.string   "user_id"
    t.string   "password_salt"
    t.string   "password_hash"
    t.string   "roles"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
