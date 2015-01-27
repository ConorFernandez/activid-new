Rails.application.routes.draw do
  resources :editors
  put "editors/:id/pause", to: "editors#pause", as: "pause_editor"
  put "editors/:id/unpause", to: "editors#unpause", as: "unpause_editor"

  resources :comments
  resources :editor_applications

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

  put "projects/:id/fix_card", to: "projects#fix_card", as: "project_fix_card"

  put "cuts/:id/approve", to: "cuts#approve", as: "approve_cut"
  put "cuts/:id/reject", to: "cuts#reject", as: "reject_cut"
  get "final_cuts/:id", to: "projects#final_cut", as: "final_cut"

  (1..4).each{ |i| get "projects/:id/step#{i}", to: "projects#step#{i}", as: "project_step#{i}" }
  put "projects/:id/claim", to: "projects#claim", as: "claim_project"

  get "/account", to: "users#edit", as: "edit_account"
  put "/account", to: "users#update"

  get "/how_it_works", to: "pages#how_it_works", as: "how_it_works_page"
  get "/pricing", to: "pages#pricing", as: "pricing_page"
  get "/about", to: "pages#about", as: "about_page"
  get "/video", to: "pages#video", as: "video_page"
  get "/gallery", to: "pages#gallery", as: "gallery_page"
  get "/tips", to: "pages#tips", as: "tips_page"
  get "/faq", to: "pages#faq", as: "faq_page"
  get "/terms", to: "pages#terms", as: "terms_page"
  get "/privacy", to: "pages#privacy", as: "privacy_page"
  get "/contact", to: "pages#contact", as: "contact_page"

  root "welcome#index"
end
