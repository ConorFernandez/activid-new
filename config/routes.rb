Rails.application.routes.draw do
  resources :editors
  resources :comments

  devise_for :users, controllers: {
    passwords: "users/passwords",
    registrations: "users/registrations",
    sessions: "users/sessions"
  }

  get "file_uploads/presigned_post", to: "file_uploads#presigned_post"
  resources :file_uploads

  resources :projects do
    resources :cuts
  end

  put "cuts/:id/approve", to: "cuts#approve", as: "approve_cut"
  get "final_cuts/:id", to: "cuts#show", as: "final_cut"

  (1..4).each{ |i| get "projects/:id/step#{i}", to: "projects#step#{i}", as: "project_step#{i}" }
  put "projects/:id/claim", to: "projects#claim", as: "claim_project"

  get "/account", to: "users#edit", as: "edit_account"
  put "/account", to: "users#update"

  root "welcome#index"
end
