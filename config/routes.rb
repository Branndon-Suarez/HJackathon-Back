Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Swagger docs
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"

  # ── WEBHOOKS (no auth required, signature-verified) ──────────
  get  "webhooks/n8n", to: "webhooks/n8n#verify"
  post "webhooks/n8n", to: "webhooks/n8n#receive"

  namespace :api do
    namespace :v1 do
      # Auth & health
      get "ping", to: "ping#show"
      post "auth/login", to: "auth#login"
      get "health", to: "health#show"

      # Reports from n8n analysis
      resources :reports, only: %i[index show] do
        get :latest, on: :collection
        get :download_pdf, on: :member
      end

      # Companies -> Leads (shallow)
      resources :companies, only: %i[index show create update] do
        resources :leads, only: %i[index create], shallow: true
      end

      # Leads -> Diagnostics (shallow)
      resources :leads, only: %i[show update] do
        resources :diagnostics, only: %i[index create], shallow: true
      end

      # Diagnostics -> StrategyPlan (nested)
      resources :diagnostics, only: %i[show update] do
        resource :strategy_plan, only: %i[show create update]
        post :ribuzz_diagnostic, on: :member
      end

      # StrategyPlans -> JourneyStages (shallow)
      resources :strategy_plans, only: %i[update] do
        resources :journey_stages, only: %i[index create], shallow: true
      end

      resources :journey_stages, only: %i[update destroy]

      # ── CHATBOT ─────────────────────────────────────────
      namespace :chatbot do
        resources :conversations, only: %i[index show create update destroy] do
          resources :messages, only: %i[index create]
        end
      end
    end
  end
end