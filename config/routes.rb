Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: "users/registrations",
    sessions: "users/sessions"
  }

  get "file_uploads/presigned_post", to: "file_uploads#presigned_post"
  resources :file_uploads

  resources :projects do
    resources :comments
    resources :cuts
  end

  (1..4).each{ |i| get "projects/:id/step#{i}", to: "projects#step#{i}", as: "project_step#{i}" }
  put "projects/:id/claim", to: "projects#claim", as: "claim_project"

  get "/account", to: "users#edit", as: "edit_account"
  put "/account", to: "users#update"

  root "welcome#index"
end
