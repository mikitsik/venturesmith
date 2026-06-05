# frozen_string_literal: true

Rails.application.routes.draw do
  root 'user_profiles#new'

  resources :user_profiles, only: %i[new create show] do
    resources :scout_runs, only: %i[create]
  end

  resources :scout_runs, only: %i[show]
end
