Rails.application.routes.draw do
  resources :lists
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  
  # Defines the root path route ("/")
  # root "articles#index"
  root "home#show"

  get "lists", to: "lists#show"
  get "instructions", to: "instructions#show"
  get "recommendations", to: "recommendations#show"
  post "recommendations", to: "recommendations#stores", as: "stores_path"
  get "recommendations/:id", to: "recommendations#number" #route to show specific recommendation
  delete "delete-item", to: "lists#delete-item"

end

