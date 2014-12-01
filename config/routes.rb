Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: "users/registrations",
    sessions: "users/sessions"
  }

  resources :file_uploads

  # used for direct uploads to s3
  get "projects/presigned_post", to: "projects#presigned_post"

  resources :projects

  (1..4).each{ |i| get "projects/:id/step#{i}", to: "projects#step#{i}", as: "project_step#{i}" }

  get "/account", to: "users#edit", as: "edit_account"
  put "/account", to: "users#update"

  root "welcome#index"
end
