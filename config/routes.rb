Rails.application.routes.draw do
  resources :emergencies
  resources :responders , except: [:new]
end
