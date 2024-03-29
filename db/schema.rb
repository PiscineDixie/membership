# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2023_07_18_155950) do
  create_table "achats", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "commande_id"
    t.integer "produit_id"
    t.string "code"
    t.integer "quantite"
    t.decimal "montant", precision: 8, scale: 2
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "activites", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "code", default: "", null: false
    t.string "description_fr", default: "", null: false
    t.string "description_en", default: "", null: false
    t.string "url_fr"
    t.string "url_en"
    t.boolean "gratuite"
    t.decimal "cout", precision: 8, scale: 2, default: "0.0"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.decimal "cout2", precision: 8, scale: 2, default: "0.0", null: false
    t.index ["code"], name: "par_code", unique: true
  end

  create_table "activites_membres", id: false, charset: "utf8", force: :cascade do |t|
    t.integer "activite_id"
    t.integer "membre_id"
    t.index ["activite_id"], name: "par_activite"
    t.index ["membre_id"], name: "par_membre"
  end

  create_table "commandes", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "famille_id"
    t.integer "paiement_id"
    t.integer "etat"
    t.decimal "total", precision: 8, scale: 2
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "constantes", id: :integer, charset: "utf8", force: :cascade do |t|
    t.decimal "baseSenior", precision: 8, scale: 2, default: "0.0"
    t.decimal "baseIndividu", precision: 8, scale: 2, default: "0.0"
    t.decimal "baseFamille", precision: 8, scale: 2, default: "0.0"
    t.decimal "activiteSenior", precision: 8, scale: 2, default: "0.0"
    t.decimal "activiteIndividu", precision: 8, scale: 2, default: "0.0"
    t.decimal "activiteFamille", precision: 8, scale: 2, default: "0.0"
    t.decimal "rabaisPreInscriptionSenior", precision: 8, scale: 2, default: "0.0"
    t.decimal "rabaisPreInscriptionIndividu", precision: 8, scale: 2, default: "0.0"
    t.decimal "rabaisPreInscriptionFamille", precision: 8, scale: 2, default: "0.0"
    t.date "finPreInscription"
    t.string "codeLeconNatation"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.decimal "cout_billet", precision: 8, scale: 2, default: "0.0"
    t.integer "age_min_individu"
    t.decimal "tps", precision: 8, scale: 6, default: "0.05"
    t.decimal "tvq", precision: 8, scale: 6, default: "0.09975"
    t.date "finCommandes"
    t.decimal "adulte_additionel", precision: 8, scale: 2, default: "25.0", null: false
  end

  create_table "cotisations", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "famille_id"
    t.decimal "cotisation_calculee", precision: 8, scale: 2, default: "0.0"
    t.decimal "cotisation_exemption", precision: 8, scale: 2, default: "0.0"
    t.decimal "non_taxable", precision: 8, scale: 2, default: "0.0"
    t.boolean "familiale"
    t.decimal "frais1", precision: 8, scale: 2, default: "0.0"
    t.string "frais1_explication", default: ""
    t.decimal "frais2", precision: 8, scale: 2, default: "0.0"
    t.string "frais2_explication", default: ""
    t.decimal "frais3", precision: 8, scale: 2, default: "0.0"
    t.string "frais3_explication", default: ""
    t.decimal "frais4", precision: 8, scale: 2, default: "0.0"
    t.string "frais4_explication", default: ""
    t.decimal "frais5", precision: 8, scale: 2, default: "0.0"
    t.string "frais5_explication", default: ""
    t.decimal "frais6", precision: 8, scale: 2, default: "0.0"
    t.string "frais6_explication", default: ""
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.decimal "rabais_preinscription", precision: 8, scale: 2, default: "0.0"
    t.integer "nombre_billets", default: 0
    t.decimal "cout_billets", precision: 8, scale: 2, default: "0.0"
    t.decimal "frais_supplementaires", precision: 8, scale: 2, default: "0.0"
    t.boolean "ecussons_remis", default: false
    t.index ["famille_id"], name: "par_famille", unique: true
  end

  create_table "familles", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "adresse1"
    t.string "adresse2"
    t.string "ville"
    t.string "province", limit: 2
    t.string "code_postal", limit: 6
    t.string "tel_soir", limit: 20
    t.string "tel_jour", limit: 20
    t.string "courriel1"
    t.string "courriel2"
    t.string "langue"
    t.string "etat"
    t.string "code_acces", default: ""
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.boolean "courriel_desabonne", default: false, null: false
    t.index ["code_acces"], name: "par_code_acces", unique: true
  end

  create_table "membres", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "famille_id"
    t.string "nom", default: "", null: false
    t.string "prenom", default: "", null: false
    t.date "naissance", null: false
    t.string "ecusson", default: "", null: false
    t.string "cours_de_natation", default: ""
    t.string "session_de_natation", default: ""
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["famille_id"], name: "par_famille"
  end

  create_table "notes", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "famille_id"
    t.date "date"
    t.string "auteur"
    t.text "info"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["famille_id"], name: "par_famille"
  end

  create_table "paiements", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "famille_id"
    t.date "date"
    t.decimal "montant", precision: 8, scale: 2, default: "0.0"
    t.decimal "non_taxable", precision: 8, scale: 2, default: "0.0"
    t.decimal "taxable", precision: 8, scale: 2, default: "0.0"
    t.decimal "tps", precision: 8, scale: 2, default: "0.0"
    t.decimal "tvq", precision: 8, scale: 2, default: "0.0"
    t.string "note"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "par", default: ""
    t.integer "no_cheque", default: 0
    t.integer "methode", default: 0
    t.index ["famille_id"], name: "par_famille"
  end

  create_table "participations", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "description_fr", null: false
    t.string "description_en", null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "participations_membres", id: false, charset: "utf8", force: :cascade do |t|
    t.integer "participation_id"
    t.integer "membre_id"
    t.index ["membre_id"], name: "par_membre"
    t.index ["participation_id"], name: "par_participation"
  end

  create_table "produits", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "titre_fr"
    t.string "titre_en"
    t.text "description_fr"
    t.text "description_en"
    t.string "tailles_fr"
    t.string "images"
    t.decimal "prix", precision: 8, scale: 2
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "recus", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "famille_id"
    t.integer "annee"
    t.string "info"
    t.string "prenom"
    t.string "nom"
    t.date "naissance", null: false
    t.decimal "montant", precision: 8, scale: 2, default: "0.0"
    t.date "montant_recu"
    t.index ["famille_id", "annee"], name: "par_famille_annee"
  end

  create_table "users", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "roles"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "courriel"
    t.string "nom"
    t.index ["courriel"], name: "users_unique_courriel", unique: true
  end

end
