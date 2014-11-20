Rails.application.routes.draw do

  get "projects/presigned_post", to: "projects#presigned_post"
  resources :projects
  (1..4).each{ |i| get "projects/:id/step#{i}", to: "projects#step#{i}", as: "project_step#{i}" }

  root "welcome#index"
end
