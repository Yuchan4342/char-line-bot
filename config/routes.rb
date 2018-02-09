Rails.application.routes.draw do
  get 'webhook/index'
  root 'webhook/index'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  post '/callback' => 'webhook#callback'
end
