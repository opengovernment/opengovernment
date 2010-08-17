OpenGov::Application.routes.draw do |map|
  match '/search' => 'districts#search', :as => 'search'
  match '/us_map(.:format)' => 'home#us_map', :as => 'us_map', :defaults => {:format => "html"}

  constraints(Subdomain) do
    match '/' => 'states#show'
    match '/search' => 'states#search', :as => 'state_search'
    match '/subscriptions' => 'states#subscribe', :as => 'state_subscriptions'

    resources :people, :only => [:show, :index] do
      member do
        get :sponsored_bills
        get :votes
      end
    end

    resources :sigs, :only => [:index, :show]
    resources :issues, :only => [:index, :show]

    resources :bills, :only => [:show], :path => '/sessions/:session/bills' do
      member do
        get :major_actions
      end
      shallow do
        resources :actions, :only => [:show]
      end
    end

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
    root :to => "admin#index"
    resources :states
    resources :people, :only => [:edit, :update]
    resources :issues, :only => [:create, :index, :destroy] do
      collection do
        get :bills
        get :categories
      end
    end
    resources :taggings, :only => [:create, :destroy]
  end

  root :to => "home#index"
#  Clearance::Routes.draw(map)
end
