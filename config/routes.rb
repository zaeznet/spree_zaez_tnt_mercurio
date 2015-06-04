Spree::Core::Engine.routes.draw do
  namespace :admin do
    resource :tnt_mercurio_settings, :only => ['show', 'update', 'edit']
  end
end
