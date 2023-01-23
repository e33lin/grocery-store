Rails.application.routes.draw do
  resources :lists
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  
  # Defines the root path route ("/")
  # root "articles#index"
  root "home#show"

  get "lists", to: "lists#show"
  get "stores", to: "stores#show"
  get "instructions", to: "instructions#show"
  post "add-item", to: "lists#add-item"
  get "recommendations", to: "recommendations#show"
  get "recommendations/:id", to: "recommendations#number" #route to show specific recommendation
  delete "delete-item", to: "lists#delete-item"

end
