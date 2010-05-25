ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.
  map.connect 'search', :controller => 'districts', :action => 'search'

  map.namespace :admin do |admin|
    admin.resources :states
  end

  map.resources :states do |state|
    state.resources :bills, :only => [:show], :path_prefix => '/states/:state_id/sessions/:session', :name_prefix => ''
    state.resources :votes, :only => [:show]
    state.resources :committees, :only => [:show, :index]
    state.resources :bills, :only => [:index]
    state.resources :people, :only => [:index], :as => 'reps'
  end
  map.resources :actions, :only => [:show]

  map.resources :people, :except => [:index], :member => {:sponsored_bills => :get} do |rep|
    rep.resources :votes, :only => [:index, :show]
  end

  map.resources :districts, :only => [:show]

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => 'home'
  # See how all your routes lay out with "rake routes"

  map.state_subscriptions "/states/ca/subscriptions", :controller => 'states', :action => 'subscribe'

  Clearance::Routes.draw(map)
  Jammit::Routes.draw(map)
end
