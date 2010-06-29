OpenGov::Application.routes.draw do |map|
  match '/search' => 'districts#search', :as => 'search'
  match '/states/ca/subscriptions' =>  'states#subscribe', :as => 'state_subscriptions'
  match '/states/:state_id/sessions/:session_id/bills/:id' =>  'bills#show', :as => 'bill'

  namespace :admin do
    resources :states
  end

  resources :states do
    resources :votes do
      member do
        get :show
      end
    end

    resources :committees do
      member do
        get :show
      end
      collection do
        get :upper
        get :lower
        get :joint
      end
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
