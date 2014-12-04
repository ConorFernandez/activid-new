Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: "users/registrations",
    sessions: "users/sessions"
  }

  resources :file_uploads

  # used for direct uploads to s3
  get "projects/presigned_post", to: "projects#presigned_post"

  resources :projects do
    resources :comments
  end

  (1..4).each{ |i| get "projects/:id/step#{i}", to: "projects#step#{i}", as: "project_step#{i}" }
  put "projects/:id/claim", to: "projects#claim", as: "claim_project"

  get "/account", to: "users#edit", as: "edit_account"
  put "/account", to: "users#update"

  root "welcome#index"
end
