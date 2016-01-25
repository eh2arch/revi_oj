CodecrackerV4::Application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  devise_for :users, :controllers => {:sessions => 'users/sessions', :registrations => 'users/registrations'}
  require 'sidekiq/web'
  authenticate :user, lambda { |u| u.admin? } do
      mount Sidekiq::Web => '/sidekiq'
  end

  root :to => 'application#home'


  controller :application do
    get 'contests' => :home
    get 'home' => :home
    get 'scoreboard/:ccode' => :scoreboard
    get 'contests/:ccode/:pcode' => :problem
    get 'contests/:ccode' => :contests
    get 'users/:username' => :users
    get 'error/404' => :error_404
    # get 'submit' => :verify_submission
    post 'scoreboard/:ccode' => :verify_submission
    get 'submissions' => :submissions
    get 'submissions/contest/:ccode' => :submissions
    get 'submissions/contest/:ccode/problem/:pcode' => :submissions
    get 'submissions/user/:user_id' => :submissions
    get 'submissions/contest/:ccode/user/:user_id' => :submissions
    get 'submissions/contest/:ccode/problem/:pcode/user/:user_id' => :submissions
    get 'get_submission_data' => :get_submission_data
    get 'rejudge' => :rejudge
    get 'view_submission/:id' => :view_submission
    get 'view_submission_details/:id' => :view_submission_details
  end

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
