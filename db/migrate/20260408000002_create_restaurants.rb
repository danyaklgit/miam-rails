class CreateRestaurants < ActiveRecord::Migration[8.1]
  def change
    create_table :restaurants, id: :uuid do |t|
      t.string :slug, limit: 100, null: false
      t.string :name, limit: 255, null: false
      t.text :description, default: ""
      t.string :tagline, limit: 255, default: ""
      t.text :logo_url, default: ""
      t.text :banner_image_url, default: ""
      t.jsonb :address, default: { street: "", city: "", postalCode: "", country: "BE" }
      t.jsonb :cuisine, default: []
      t.jsonb :hours, default: {}
      t.string :currency, limit: 10, default: "EUR"
      t.string :timezone, limit: 50, default: "Europe/Brussels"
      t.decimal :tax_rate, precision: 5, scale: 2, default: 21
      t.string :locale, limit: 10, default: "fr-BE"
      t.jsonb :settings, default: {
        orderTypes: { dineIn: true, takeaway: false, delivery: false },
        dineInMode: "ordering",
        requiresAccount: { takeaway: true, delivery: true }
      }
      t.jsonb :theme, default: {
        primaryColor: "#000000",
        secondaryColor: "#f59e0b",
        backgroundColor: "#ffffff",
        textColor: "#1f2937",
        fontFamily: "Inter",
        bannerImageUrl: "",
        backgroundImageUrl: "",
        logoUrl: "",
        menuStyle: "cards"
      }
      t.jsonb :stripe, default: {
        stripeAccountId: "",
        platformFeePercent: 2,
        pricingModel: "transaction",
        onboardingComplete: false
      }
      t.text :google_business_url, default: ""
      t.string :status, limit: 20, null: false, default: "active"
      t.string :owner_id, limit: 128, null: false

      t.timestamps
    end

    add_index :restaurants, :slug, unique: true
    add_index :restaurants, :owner_id
  end
end
