Rails.application.routes.draw do
  root "github_info#index"
  get "show", to: "github_info#show"
end
