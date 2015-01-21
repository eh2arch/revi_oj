require 'sidekiq'
require 'sidekiq/web'

Sidekiq::Web.use(Rack::Auth::Basic) do |user, password|
  [user, password] == ["bowchikibowwow", "skyfullofstars_coldplay`love"]
end