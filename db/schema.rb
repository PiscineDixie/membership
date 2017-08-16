# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170629004532) do

  create_table "achats", force: :cascade do |t|
    t.integer  "commande_id", limit: 4
    t.integer  "produit_id",  limit: 4
    t.string   "code",        limit: 255
    t.integer  "quantite",    limit: 4
    t.decimal  "montant",                 precision: 8, scale: 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "activites", force: :cascade do |t|
    t.string   "code",           limit: 255,                         default: "",  null: false
    t.string   "description_fr", limit: 255,                         default: "",  null: false
    t.string   "description_en", limit: 255,                         default: "",  null: false
    t.string   "url_fr",         limit: 255
    t.string   "url_en",         limit: 255
    t.boolean  "gratuite"
    t.decimal  "cout",                       precision: 8, scale: 2, default: 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "activites", ["code"], name: "par_code", unique: true, using: :btree

  create_table "activites_membres", id: false, force: :cascade do |t|
    t.integer "activite_id", limit: 4
    t.integer "membre_id",   limit: 4
  end

  add_index "activites_membres", ["activite_id"], name: "par_activite", using: :btree
  add_index "activites_membres", ["membre_id"], name: "par_membre", using: :btree

  create_table "commandes", force: :cascade do |t|
    t.integer  "famille_id",  limit: 4
    t.integer  "paiement_id", limit: 4
    t.integer  "etat",        limit: 4
    t.decimal  "total",                 precision: 8, scale: 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "constantes", force: :cascade do |t|
    t.decimal  "baseSenior",                               precision: 8, scale: 2, default: 0.0
    t.decimal  "baseIndividu",                             precision: 8, scale: 2, default: 0.0
    t.decimal  "baseFamille",                              precision: 8, scale: 2, default: 0.0
    t.decimal  "activiteSenior",                           precision: 8, scale: 2, default: 0.0
    t.decimal  "activiteIndividu",                         precision: 8, scale: 2, default: 0.0
    t.decimal  "activiteFamille",                          precision: 8, scale: 2, default: 0.0
    t.decimal  "rabaisPreInscriptionSenior",               precision: 8, scale: 2, default: 0.0
    t.decimal  "rabaisPreInscriptionIndividu",             precision: 8, scale: 2, default: 0.0
    t.decimal  "rabaisPreInscriptionFamille",              precision: 8, scale: 2, default: 0.0
    t.date     "finPreInscription"
    t.string   "codeLeconNatation",            limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "cout_billet",                              precision: 8, scale: 2, default: 0.0
    t.integer  "age_min_individu",             limit: 4
    t.decimal  "tps",                                      precision: 8, scale: 6, default: 0.05
    t.decimal  "tvq",                                      precision: 8, scale: 6, default: 0.09975
    t.date     "finCommandes"
  end

  create_table "cotisations", force: :cascade do |t|
    t.integer  "famille_id",            limit: 4
    t.decimal  "cotisation_calculee",               precision: 8, scale: 2, default: 0.0
    t.decimal  "cotisation_exemption",              precision: 8, scale: 2, default: 0.0
    t.decimal  "non_taxable",                       precision: 8, scale: 2, default: 0.0
    t.boolean  "familiale"
    t.decimal  "frais1",                            precision: 8, scale: 2, default: 0.0
    t.string   "frais1_explication",    limit: 255,                         default: ""
    t.decimal  "frais2",                            precision: 8, scale: 2, default: 0.0
    t.string   "frais2_explication",    limit: 255,                         default: ""
    t.decimal  "frais3",                            precision: 8, scale: 2, default: 0.0
    t.string   "frais3_explication",    limit: 255,                         default: ""
    t.decimal  "frais4",                            precision: 8, scale: 2, default: 0.0
    t.string   "frais4_explication",    limit: 255,                         default: ""
    t.decimal  "frais5",                            precision: 8, scale: 2, default: 0.0
    t.string   "frais5_explication",    limit: 255,                         default: ""
    t.decimal  "frais6",                            precision: 8, scale: 2, default: 0.0
    t.string   "frais6_explication",    limit: 255,                         default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "rabais_preinscription",             precision: 8, scale: 2, default: 0.0
    t.integer  "nombre_billets",        limit: 4,                           default: 0
    t.decimal  "cout_billets",                      precision: 8, scale: 2, default: 0.0
    t.decimal  "frais_supplementaires",             precision: 8, scale: 2, default: 0.0
    t.boolean  "ecussons_remis",                                            default: false
  end

  add_index "cotisations", ["famille_id"], name: "par_famille", unique: true, using: :btree

  create_table "familles", force: :cascade do |t|
    t.string   "adresse1",    limit: 255
    t.string   "adresse2",    limit: 255
    t.string   "ville",       limit: 255
    t.string   "province",    limit: 2
    t.string   "code_postal", limit: 6
    t.string   "tel_soir",    limit: 20
    t.string   "tel_jour",    limit: 20
    t.string   "courriel1",   limit: 255
    t.string   "courriel2",   limit: 255
    t.string   "langue",      limit: 255
    t.string   "etat",        limit: 255
    t.string   "code_acces",  limit: 255, default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "familles", ["code_acces"], name: "par_code_acces", unique: true, using: :btree

  create_table "membres", force: :cascade do |t|
    t.integer  "famille_id",          limit: 4
    t.string   "nom",                 limit: 255, default: "", null: false
    t.string   "prenom",              limit: 255, default: "", null: false
    t.date     "naissance",                                    null: false
    t.string   "ecusson",             limit: 255, default: "", null: false
    t.string   "cours_de_natation",   limit: 255, default: ""
    t.string   "session_de_natation", limit: 255, default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "membres", ["famille_id"], name: "par_famille", using: :btree

  create_table "notes", force: :cascade do |t|
    t.integer  "famille_id", limit: 4
    t.date     "date"
    t.string   "auteur",     limit: 255
    t.text     "info",       limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "notes", ["famille_id"], name: "par_famille", using: :btree

  create_table "paiements", force: :cascade do |t|
    t.integer  "famille_id",  limit: 4
    t.date     "date"
    t.decimal  "montant",                 precision: 8, scale: 2, default: 0.0
    t.decimal  "non_taxable",             precision: 8, scale: 2, default: 0.0
    t.decimal  "taxable",                 precision: 8, scale: 2, default: 0.0
    t.decimal  "tps",                     precision: 8, scale: 2, default: 0.0
    t.decimal  "tvq",                     precision: 8, scale: 2, default: 0.0
    t.string   "note",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "par",         limit: 255,                         default: ""
    t.integer  "no_cheque",   limit: 4,                           default: 0
    t.integer  "methode",     limit: 4,                           default: 0
  end

  add_index "paiements", ["famille_id"], name: "par_famille", using: :btree

  create_table "participations", force: :cascade do |t|
    t.string   "description_fr", limit: 255, null: false
    t.string   "description_en", limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "participations_membres", id: false, force: :cascade do |t|
    t.integer "participation_id", limit: 4
    t.integer "membre_id",        limit: 4
  end

  add_index "participations_membres", ["membre_id"], name: "par_membre", using: :btree
  add_index "participations_membres", ["participation_id"], name: "par_participation", using: :btree

  create_table "produits", force: :cascade do |t|
    t.string   "titre_fr",       limit: 255
    t.string   "titre_en",       limit: 255
    t.text     "description_fr", limit: 65535
    t.text     "description_en", limit: 65535
    t.string   "tailles_fr",     limit: 255
    t.string   "images",         limit: 255
    t.decimal  "prix",                         precision: 8, scale: 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "recus", force: :cascade do |t|
    t.integer "famille_id",   limit: 4
    t.integer "annee",        limit: 4
    t.string  "info",         limit: 255
    t.string  "prenom",       limit: 255
    t.string  "nom",          limit: 255
    t.date    "naissance",                                                      null: false
    t.decimal "montant",                  precision: 8, scale: 2, default: 0.0
    t.date    "montant_recu"
  end

  add_index "recus", ["famille_id", "annee"], name: "par_famille_annee", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "roles",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "courriel",   limit: 255
    t.string   "nom",        limit: 255
  end

  add_index "users", ["courriel"], name: "users_unique_courriel", unique: true, using: :btree

end
