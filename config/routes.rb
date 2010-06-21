OpenGov::Application.routes.draw do |map|
  match '/search' => 'districts#search', :as => 'search'
  match '/states/ca/subscriptions' =>  'states#subscribe', :as => 'state_subscriptions'

  namespace :admin do
    resources :states
  end

  resources :states do
    resources :bills do
      member do
        get :show
#        , :path_prefix => '/states/:state_id/sessions/:session', :name_prefix => ''
      end
    end

    resources :votes do
      member do
        get :show
      end
    end

    resources :committees do
      member do
        get :show
      end
#      , :collection => {:upper => :get, :lower => :get, :joint => :get}
    end

    resources :bills do
      member do
        get :index
      end
    end

    resources :people do
      member do
        get :index, :as => 'reps'
      end
    end
  end

  resources :actions do
    member do
      get :show
    end
  end

  resources :people do
    member do
      get :sponsored_bills
      get :votes
    end
  end

  resources :districts do
    member do
      get :show
    end
  end

  resources :sigs do
    member do
      get :show
      get :index
    end
  end

  root :to => "home#index"
#  Clearance::Routes.draw(map)
end
