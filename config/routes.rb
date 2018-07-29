Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'top#index'

  get 'top/index'
  get 'top' => 'top#index'

  post 'callback' => 'webhook#callback'
end
