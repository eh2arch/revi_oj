CodecrackerV4::Application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  devise_for :users, :controllers => {:sessions => 'users/sessions', :registrations => 'users/registrations'}
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  root :to => 'application#home'

  get 'contests' => 'application#home'
  get 'home' => 'application#home'
  get 'scoreboard/:ccode' => 'application#scoreboard'
  get 'contests/:ccode/:pcode' => 'application#problem'
  get 'contests/:ccode' => 'application#contests'
  get 'users/:username' => 'application#users'
  get 'error/404' => 'error#error_404'
  get 'submit' => 'application#verify_submission'
  post 'submit' => 'application#verify_submission'

  # You can have the root of your site routed with "root"

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
  # match ':controller(/:action(/:id))', :via => [:get, :post]
end
