Rails.application.routes.draw do

  resources :projects
  (1..4).each{ |i| get "projects/:id/step#{i}", to: "projects#step#{i}", as: "project_step#{i}" }

  root "welcome#index"
end
