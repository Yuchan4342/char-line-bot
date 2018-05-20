Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  post '/callback' => 'webhook#callback'

  root 'top#index'

  get 'top/index'
  get 'top' => 'top#index'

  get 'webhook/index'
  get 'webhook' => 'webhook#index'

end
