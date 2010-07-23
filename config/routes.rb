OpenGov::Application.routes.draw do |map|
  match '/search' => 'districts#search', :as => 'search'
  match '/states/ca/subscriptions' =>  'states#subscribe', :as => 'state_subscriptions'

  resources :actions, :only => [:show]
  resources :districts, :only => [:show]
  resources :sigs, :only => [:index, :show]
  resources :bills, :only => [:show], :path => '/states/:state_id/sessions/:session/bills'
  resources :issues, :only => [:index, :show]

  resources :people do
    member do
      get :sponsored_bills
      get :votes
    end
  end

  resources :states do
    get :search, :on => :member
    resources :votes, :only => [:show]
    resources :bills, :only => [:index]
    resources :people, :only => [:index], :as => 'reps'

    resources :committees, :only => [:show] do
      collection do
        get :upper
        get :lower
        get :joint
      end
    end
  end

  namespace :admin do
    resources :states
    resources :people
    resources :issues, :only => [:create, :index]
  end

  root :to => "home#index"
#  Clearance::Routes.draw(map)
end
