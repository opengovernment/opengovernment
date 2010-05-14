ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.
  map.connect 'search', :controller => 'districts', :action => 'search'

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller

  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  map.namespace :admin do |admin|
     admin.resources :states
  end

  map.resources :states do |state|
    state.resources :bills, :only => [:index, :show], :path_prefix => '/states/:state_id/sessions/:session_id', :name_prefix => ''
    state.resources :people, :only => [:index], :as => 'reps'
  end
  map.resources :people, :except => [:index], :member => {:sponsored_bills => :get}

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => 'home'
  # See how all your routes lay out with "rake routes"

  map.state_subscriptions "/states/ca/subscriptions", :controller => 'states', :action => 'subscribe'

  Clearance::Routes.draw(map)
  Jammit::Routes.draw(map)
end
