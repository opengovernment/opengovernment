OpenGov::Application.routes.draw do
  devise_for :users, :path => 'users', :path_names => { :sign_in => 'login', :sign_out => 'logout' }

  match '/us_map(.:format)' => 'home#us_map', :as => 'us_map', :defaults => {:format => "html"}

  match '/people/govtrack/:govtrack_id' => 'home#person_from_govtrack_id'

  constraints(Subdomain) do
    match '/search' => 'states#search', :as => 'state_search'

    match '/widgets' => 'widgets#index', :as => 'widgets'

    resources :people, :only => [:show] do
      collection do
        get :search
      end
      member do
        get :news
        get :sponsored_bills
        get :votes
        get :social
        get :money_trail
        get :discuss
        get :contact
        get :videos
        get :committees
        get :ratings
      end
    end

    resources :sigs, :only => [:index, :show]
    resources :money_trails, :only => [:index, :show], :path => 'money_trail'

#    match '/bills', :to => 'bills#index', :as => 'bills'
#    match '/bills/upper', :to => 'bills#upper', :as => 'bills_upper'
#    match '/bills/lower', :to => 'bills#lower', :as => 'bills_lower'

    match '/' => 'states#show'
    match '/index' => 'states#show'

    scope '(/sessions/:session)' do
      match '/' => 'states#show', :as => 'state'

      resources :people, :only => [:index] do
        collection do
          get :search
        end
      end

      resources :bills, :only => [:show, :index] do
        collection do
          get :upper
          get :lower
        end
        member do
          get :news
          get :money_trail
          get :social
          get :votes
          get :videos
          get :discuss
          get :major_actions
          get :actions
          get :sponsors
          get :documents
        end  
        shallow do
          resources :documents, :only => [:show]
          resources :actions, :only => [:show]
          resources :votes, :only => [:show]
        end
      end

      resources :issues, :only => [:index, :show]
      resources :subjects, :only => [:index, :show]
    end
  end

  resources :committees, :only => [:show, :index] do
    collection do
      get :upper
      get :lower
      get :joint
    end
  end

  namespace :admin do
    root :to => "home#index"
    resources :states
    resources :people, :only => [:edit, :update]
    resources :issues, :only => [:create, :index, :destroy, :update] do
      collection do
        get :bills
        get :categories
      end
    end
    resources :taggings, :only => [:create, :destroy]
  end

  match '/search' => 'districts#search', :as => 'search'

  # Track traffic on a given page
  match '/tracking.gif' => TrackingApp

  root :to => "home#index"

  # This route renders home#index without a geoip/cookie
  # redirect.
  match '/home' => 'home#home'

  resources :pages, :only => :show
end
