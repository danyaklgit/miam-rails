Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Dashboard (authenticated owner/staff)
  namespace :dashboard do
    get "/",                to: "overview#show"
    post "/switch-restaurant", to: "restaurants#switch", as: :switch_restaurant
    resources :restaurants,  only: [:new, :create]
    resources :orders,      only: [:index, :update]
    get "/floor",           to: "floor#index"
    get "/menu",            to: "menus#index"
    resources :menus,       only: [:create, :update, :destroy]
    resources :categories,  only: [:create, :update, :destroy]
    resources :menu_items,  only: [:create, :update, :destroy]
    resources :tables,      only: [:index, :create, :destroy] do
      collection { post :bulk_create }
    end
    resource :theme,        only: [:edit, :update]
    resource :settings,     only: [:edit, :update]
    resources :reservations, only: [:index, :update, :destroy]
    resources :offers
    get "/analytics",       to: "analytics#index"
  end

  # Admin (super admin)
  namespace :admin do
    get "/",                to: "overview#show"
    resources :restaurants, only: [:index, :show, :update]
    get "/analytics",       to: "analytics#index"
  end

  # Display (kitchen/bar/floor/hostess)
  scope "/display" do
    get "/kitchen/:restaurant_id",  to: "display/kitchen#show"
    get "/bar/:restaurant_id",      to: "display/bar#show"
    get "/floor/:restaurant_id",    to: "display/floor#show"
    get "/hostess/:restaurant_id",  to: "display/hostess#show"
    get "/orders/:restaurant_id",   to: "display/orders#show"
  end

  # API (JSON for Stimulus AJAX)
  namespace :api do
    resources :order_items, only: [] do
      member do
        patch :update_status
        patch :update_quantity
        delete :destroy
      end
      collection do
        patch :bulk_update_status
      end
    end
    post "/sessions/join",                to: "sessions#join"
    post "/sessions/:id/close",           to: "sessions#close"
    get  "/orders/:id",                   to: "orders#show"
    post "/orders",                       to: "orders#create"
    post "/orders/:id/items",             to: "orders#add_items"
    post "/orders/:id/confirm",           to: "orders#confirm"
    post "/orders/:id/claim-items",       to: "orders#claim_items"
    patch "/orders/:id/status",           to: "orders#update_status"
    post "/orders/:id/pay",               to: "orders#pay"
    post "/payments",                     to: "payments#create"
    post "/reviews",                      to: "reviews#create"
    get  "/reviews/:restaurant_id",       to: "reviews#index"
    post "/promo/validate",               to: "promo_codes#validate"
    post "/upload",                       to: "uploads#create"
    post "/cart/add",                     to: "cart#add"
    delete "/cart/remove/:index",         to: "cart#remove"
    patch "/cart/update/:index",          to: "cart#update_quantity"
    delete "/cart/clear",                 to: "cart#clear"
    patch "/reservations/:id/status",     to: "reservations#update_status"
    delete "/reservations/:id",           to: "reservations#destroy"
    get  "/customers/me/addresses",       to: "customer_addresses#index"
    post "/customers/me/addresses",       to: "customer_addresses#create"
    patch "/customers/me/addresses/:id",  to: "customer_addresses#update"
    delete "/customers/me/addresses/:id", to: "customer_addresses#destroy"
    get "/restaurants/:id/analytics/:type", to: "analytics#show"
  end

  root "pages#home"

  # Customer (public, per-restaurant slug) — MUST be last (catch-all /:slug)
  scope "/:slug", as: :restaurant, constraints: { slug: /[a-z0-9\-]+/ } do
    get "/",                            to: "customer/landing#show"
    get "/menu",                        to: "customer/menus#show"
    get "/table/:table_number",         to: "customer/tables#show"
    get "/table/:table_number/cart_drawer", to: "customer/tables#cart_drawer"
    get "/checkout",                    to: "customer/checkouts#show"
    post "/checkout",                   to: "customer/checkouts#create"
    get "/order/:order_id",             to: "customer/orders#show"
    get "/receipt/:order_id",           to: "customer/receipts#show"
    get "/reserve",                     to: "customer/reservations#new"
    post "/reserve",                    to: "customer/reservations#create"
    get "/reserve/confirmation/:id",    to: "customer/reservations#confirmation"
  end
end
