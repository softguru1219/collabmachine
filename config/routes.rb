Rails.application.routes.draw do
  mount RedactorRails::Engine => '/redactor_rails'
  # mount DocMate::Engine, at: "/docs", as: "docs"

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  devise_for :users, only: :omniauth_callbacks, controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks'
  }

  scope path: "(:locale)", shallow_path: "(:locale)", locale: /en|fr/ do
    devise_for :users, controllers: {
      sessions: 'users/sessions',
      registrations: 'users/registration',
      passwords: 'users/passwords',
      invitations: 'users/invitations'
    }, skip: [:omniauth_callbacks]

    devise_scope :user do
      # registration_type: talent | client | coach | entrepreneur
      # TODO: fix situations where registration_type is not in list

      # get "/signup/:registration_type", to: 'users/registration#new', as: :new_user_with_role
      get "/creation/:registration_type", to: 'users/registration#new', as: :new_user_with_role
    end

    resources :users, except: [:new, :create] do
      member do
        patch :update_payment_information
      end

      collection do
        get :admin_index
      end

      resources :attributes, as: 'meta_attributes', except: [:index, :show]
    end
    resources :sectors
    resources :softwares
    resources :business_domains do
      resources :business_sub_domains do
        resources :business_categories
      end
    end

    resources :user_steps
    resources :user_steps_talent
    resources :user_steps_client
    resources :user_steps_coach
    resources :user_steps_entrepreneur

    resources :trackers

    post 'users/send_onboarding_message' => 'users#send_onboarding_message'
    post 'products/send_message_to_merchant' => 'products#send_message_to_merchant'
    post 'subscription_plans/send_message_to_admin_partner' => 'subscription_plans#send_message_to_admin_partner'
    resources :specialists
    resources :specialties
    resources :invoices do
      patch :update_payment_information, on: :member
    end

    get 'users/payment_information' => 'users#payment_information'
    get 'employees' => 'users#employees', as: 'users_employees'
    post 'create/employee' => 'users#create_employee', as: "new_users_employee"
    patch 'update_payment_information' => 'invoices#update_payment_information'

    post 'resend_invitation' => 'users#resend_invitation', as: 'resend_invitation'
    post 'fetch_user_data' => 'users#fetch_user_data', as: 'fetch_user_data'
    post 'fetch_all_users_data' => 'users#fetch_all_users_data', as: 'fetch_all_users_data'
    get 'import_coachs', to: 'users#import_coachs', as: 'import_coachs'
    get 'import_participants', to: 'users#import_participants', as: 'import_participants'
    get 'reset_card', to: 'users#reset_card', as: 'reset_card'

    get '/exchanges/testing' => 'exchanges#testing', as: 'testing'
    resources :shares
    get 'destroy_suggestions' => 'applicants#destroy_suggestions'
    post 'toggle_im_interested_to_mission' => 'applicants#toggle_im_interested_to_mission', as: 'toggle_im_interested_to_mission'
    post 'set_applicant_state' => 'applicants#set_applicant_state', as: 'set_applicant_state'
    post 'admin_set_applicant' => 'applicants#admin_set_applicant', as: 'admin_set_applicant'
    resources :user_messages
    get '/feedback', to: 'user_messages#new', as: 'feedback'
    resources :projects
    get 'submit_project_for_review' => 'projects#submit_project_for_review', as: 'submit_project_for_review'
    get 'mark_project_reviewed' => 'projects#mark_project_reviewed', as: 'mark_project_reviewed'
    get 'open_project_for_candidates' => 'projects#open_project_for_candidates', as: 'open_project_for_candidates'
    resources :missions, except: [:new, :create] do
      collection { post :sort }
    end
    get 'submit_mission_for_review' => 'missions#submit_mission_for_review', as: 'submit_mission_for_review'
    get 'mark_mission_reviewed' => 'missions#mark_mission_reviewed', as: 'mark_mission_reviewed'
    get 'open_mission_for_candidates' => 'missions#open_mission_for_candidates', as: 'open_mission_for_candidates'
    get 'start'             => 'missions#start'
    get 'finish'            => 'missions#finish'
    get 'reopen'            => 'missions#reopen'
    get 'archive'           => 'missions#archive'
    get 'mission_hold'      => 'missions#hold'
    get 'project_hold'      => 'projects#hold'

    post 'slack_notify_new_mission', to: "missions#slack_notify_new_mission", as: 'slack_notify_new_mission'

    resources :milestones
    resources :messages
    resources :taxes, only: [:create, :destroy]
    resources :financial_infos
    resources :transactions, only: :create
    resources :estimates, except: [:edit, :update]
    resources :insurance_quotes, only: [:new, :create]

    resources :tags do
      collection do
        get :tag_cloud
      end
    end
    post 'merge' => 'tags#merge', as: 'merge_tag_with'
    delete 'destroy_orphean_tags' => 'tags#destroy_orphean_tags', as: 'destroy_orphean_tags'

    # RIP
    resources :machines, except: [:create]
    resources :exchanges
    # RIP

    get 'accept_terms' => 'users#accept_terms', as: 'accept_terms'
    put 'accept_terms_for_current_user' => 'users#accept_terms_for_current_user', as: 'accept_terms_for_current_user'

    # Named
    get 'contact', to: "hello#contact", as: 'contact'
    get 'dashboard', to: "dashboard#index", as: 'dashboard'
    get 'dashboard/metrics', to: "dashboard#metrics", as: 'metrics'
    get 'dashboard/missions', to: "dashboard#missions", as: 'dashboard_admin_missions'
    get 'dashboard/users', to: "dashboard#users", as: 'dashboard_admin_users'
    get 'participation-system', to: 'dashboard#participation_system', as: 'participation_system'
    get 'dashboard/slack_users', to: "dashboard#slack_users", as: 'slack_users'

    # Templating contracts
    get 'dashboard/master_service_agreement', to: "dashboard#master_service_agreement", as: 'master_service_agreement'
    get 'get_contract_data' => 'dashboard#get_contract_data', as: 'get_contract_data'

    # Blitz coaching
    post 'export_participants', to: 'users#export_participants', as: 'export_participants'
    post 'export_coachs', to: 'users#export_coachs', as: 'export_coachs'
    if Rails.env.production?
      get 'blitz-coaching', controller: 'projects', action: :show, id: 149, as: 'blitz-coaching'
    else
      get 'blitz-coaching', controller: 'projects', action: :show, id: 2, as: 'blitz-coaching'
    end

    post 'blitz-coaching/set_participation_next_blitz' => 'users#set_participation_next_blitz'
    get 'blitz-coaching/coachs', to: 'dashboard#coachs', as: 'blitz-coachs'
    get 'blitz-coaching/participants', to: 'dashboard#participants', as: 'blitz-participants'
    get 'blitz-coaching/logs', to: 'dashboard#blitz_logs', as: 'blitz-logs'

    get 'blitz-coaching/followup(/:from)', to: 'dashboard#blitz_followup', as: 'blitz-followup'
    get 'blitz-coaching/meeting_participants', to: 'dashboard#meeting_participants', as: 'blitz-meeting_participants'
    get 'meet/:room', to: "dashboard#meet", as: 'meet'

    get 'ten_slides' => 'hello#ten_slides', as: 'ten_slides'
    get '/presentation/digital-entrepreneurs' => 'hello#digital_entrepreneurs', as: 'digital_entrepreneurs'

    # TODO: refactor then publish
    # get 'about' => 'hello#about', as: 'about'

    # old version
    get 'hello_first' => 'hello#index_first', as: 'landing_first'

    get 'hello' => 'hello#index', as: 'landing'
    get 'hello/wiphomepage' => 'hello#wiphomepage', as: 'wiphomepage'
    get '/hello/wiphomepage/results', to: "hello#results", as: 'results'
    get '/hello/wiphomepage/results/:id', to: "hello#show_results", as: 'show_results'
    post 'send_results', to: 'hello#send_results', as: 'send_results'
    get '/hello/wiphomepage/thankyou/:wip_id/:specialty_id', to: 'hello#final_results', as: 'final_results'
    get '/hello/wiphomepage/email', to: 'hello#results_email', as: 'results_email'
    get 'hello/teaserhomepage' => 'hello#teaser_homepage', as: 'teaser_homepage'
    get 'payment' => 'hello#payment', as: 'payment'
    get 'payment_gateway' => 'hello#payment_gateway', as: 'payment_gateway'

    get 'mastermind-pointdebascule' => 'hello#mastermind_pointdebascule', as: 'mastermind_pointdebascule'
    get 'trousse-participant-automne-2021' => 'dashboard#trousse_participant_automne_2021', as: 'trousse_participant_automne_2021'
    get 'sandbox-program' => 'hello#sandbox_program', as: 'sandbox_program'
    get 'ta-place-de-service' => 'hello#your_serviceplace', as: 'your_serviceplace' # landing page expo entrepreneur 2022

    # specialties
    get 'avantages-membre-reseau-collabmachine' => 'hello#avantages_membre', as: 'avantages_membre'
    post 'filter-specialties' => 'specialties#filter_specialties', as: 'filter_specialties'
    post '/specialties/update-active' => 'specialties#update_active', as: 'update_active'
    get 'comment-obtenir-des-mandats' => 'hello#get_contracts', as: 'get_contracts'
    get 'comment-obtenir-un-specialiste' => 'hello#get_specialist', as: 'get_specialist'
    get 'projet-informatique-e-commerce-marketing-a-realiser' => 'hello#propose_project', as: 'propose_project'

    get 'termes-et-conditions' => 'hello#terms_conditions', as: 'terms_conditions'
    get 'termes-utilisation' => 'hello#terms_use', as: 'terms_use'
    get 'politique-confidentialite' => 'hello#privacy_policy', as: 'privacy_policy'

    get 'sandbox' => 'hello#sandbox', as: 'sandbox'
    get 'styledeck' => 'hello#styledeck', as: 'styledeck'
    get 'hire' => 'hello#hire', as: 'hire'
    get 'work' => 'hello#work', as: 'work'
    get 'team' => 'hello#team', as: 'team'
    get 'partners' => 'hello#partners', as: 'partners'
    get 'sitemap' => 'hello#sitemap', as: 'sitemap'
    get 'randomly', to: 'hello#randomly', as: 'randomly' # Temporary hardcoded product page for randomly

    #  stripe charge controller
    scope '/checkout' do
      post 'create', to: 'checkout#create', as: :checkout_create
      get 'cancel', to: 'checkout#cancel', as: :checkout_cancel
      get 'success', to: 'checkout#success', as: :checkout_success
    end

    get '/:locale', to: redirect('/%{locale}/hello')

    namespace :admin do
      resources :products, only: [:index, :show]
      resources :orders, only: [:index]
    end

    resources :products do
      resources :specific_user_reviews
      resources :reviews, only: [:new, :create]
      member do
        get :publish
        get :archive
        get :reject
        get :embed
        get :embed_graphic
        get :embed_link
      end

      resources :product_recommendations, only: [:new] do
        collection do
          # we `get` instead of `create` here because turbolinks doesn't let us post with Turbolinks.visit
          get :save
        end
      end
    end

    resource :serviceplace, only: [:show] do
      resources :product_categories, only: [:show]
    end

    resources :subscription_plans, only: [:index]

    resources :shopping_cart_products, only: [:create, :destroy]
    resource :serviceplace_checkout, only: [:show] do
      get :confirm_payment_information
      patch :update_card
      get :confirm_purchase
      post :do_confirm_purchase
      get :view_invoice
    end

    resources :subscription_checkouts, only: [:new] do
      collection do
        get :success
        get :cancel
      end
    end

    resources :purchases
    resources :orders do
      member do
        get :invoice
      end
    end

    resources :stripe_customer_portal_sessions, only: [:new]

    # blog
    resources :posts
    resources :pages
    get 'blog', to: 'pages#show', id: "blog", as: :blog

    # %w[dashblog home about category].each do |page|
    #   get page, to: 'pages#show_by_slug', slug: page
    # end

    # %w[culture entertainment style news].each do |category|
    #   get category, to: 'posts#show_category', slug: category # <<< passer le :path ici ?
    # end
  end

  post "stripe_webhooks/:secret", to: "stripe_webhooks#create"

  # No lang
  get 'all_tags' => 'tags#all_tags', as: 'all_tags'

  root to: 'hello#index'

end
