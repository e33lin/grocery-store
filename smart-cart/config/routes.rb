Rails.application.routes.draw do
  resources :lists
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  
  # Defines the root path route ("/")
  # root "articles#index"
  root "home#show"

  get "lists", to: "lists#show"
  get "instructions", to: "instructions#show"
  get "instructions/how", to: "instructions#how", as: "how"
  get "instructions/stores", to: "instructions#stores", as: "instr_stores"
  get "instructions/terms", to: "instructions#terms", as: "terms"
  get "recommendations", to: "recommendations#show"
  post "recommendations", to: "recommendations#stores", as: "stores_path"
  get "recommendations/:id", to: "recommendations#number", as: "number" #route to show specific recommendation
  delete "delete_item", to: "lists#delete_item"
  get "feedback/:id", to: "feedback#show"
  post "create/:id", to: "feedback#create", as: "create_feedback"

end

 