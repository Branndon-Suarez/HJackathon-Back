Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      get "ping", to: "ping#show"
      post "auth/login", to: "auth#login"
      get "health", to: "health#show"

      resources :companies, only: %i[index show create update] do
        resources :leads, only: %i[index create], shallow: true
      end

      resources :leads, only: %i[show update] do
        resources :diagnostics, only: %i[index create], shallow: true
      end

      resources :diagnostics, only: %i[show update] do
        resource :strategy_plan, only: %i[show create update]
      end

      resources :strategy_plans, only: %i[update] do
        resources :journey_stages, only: %i[index create], shallow: true
      end

      resources :journey_stages, only: %i[update destroy]
    end
  end
end
