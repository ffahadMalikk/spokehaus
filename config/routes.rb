require 'sidekiq/web'

Rails.application.routes.draw do
  authenticate :user, -> (u) { Rails.env.development? || u.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  # Authentication
  devise_for :users, controllers: {
    sessions: 'sessions',
    registrations: 'registrations'} do
    delete 'sign_out', :to => 'devise/sessions#destroy', :as => :destroy_user_session
  end

  # Static Pages
  get '/' => 'high_voltage/pages#show', id: 'home', as: :home
  get '/home', to: redirect('/')

  get '/experience' => 'high_voltage/pages#show', id: 'experience', as: :experience
  get '/ride' => 'high_voltage/pages#show', id: 'ride', as: :ride
  get '/terms-and-conditions' => 'high_voltage/pages#show',
      id: 'terms-and-conditions', as: :toc
  get '/privacy-policy' => 'high_voltage/pages#show',
      id: 'privacy-policy', as: :privacy_policy
  get '/aboutus' => 'high_voltage/pages#show', id: 'aboutus', as: :aboutus
  get '/contactus' => 'high_voltage/pages#show', id: 'contactus', as: :contactus
  get '/faq' => 'high_voltage/pages#show', id: 'faq', as: :faq
  get '/instructor' => 'high_voltage/pages#show', id: 'instructor', as: :instructor

  # Booking
  get '/calendar/(:date)' => 'calendar#show', as: :calendar

  resources :bookings, only: [:edit, :update, :destroy] do
    collection do
      get :complete, as: :complete_pending
    end
  end

  resources :scheduled_classes, only: [] do
    resources :bookings, only: [:new, :create]
    resources :waitlist_entries, only: [:create, :destroy] do
      collection do
        get :accept
        get :decline
      end
    end
  end

  # Instructors
  resources :instructors, only: [:index, :show]
  resources :packages, only: :index do
    collection do
      post :buy
    end
  end

  # User Profile
  get '/profile' => 'user#profile', as: :user_profile
  get '/admin/sign_up_sheet/:id' => 'admin#sign_up_sheet', as: :sign_up_sheet

  # Gifting
  resources :gifts, only: [:new, :create]

end
