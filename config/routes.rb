ActionController::Routing::Routes.draw do |map|

  map.resources :users,
    :member => {
    :edit_password => :get,
    :update_password => :put,
    :add_culture_provider => :post,
    :reset_password => :get
  }, :collection => {
    :request_password_reset => :get,
    :send_password_reset_confirmation => :post
  }

  map.resources :statistics, :only => [ :index ],
    :member => { :visitors => :get,
                 :questionaires => :get
               }
  
  map.resources :culture_providers do |cp|
    cp.resources :images, :except => [ :show, :edit, :update, :new ],
      :member => { :set_main => :get }
  end

  map.resources :events, :except => [ :index ], :member => {
    :handle_links => :get,
    :add_link => :post,
    :remove_link => :delete
  }, :collection => {
    :options_list => :get
  } do |e|
    e.resources :images, :except => [ :show, :edit, :update, :new ]
    e.resources :attachments, :except => [ :edit, :update, :new ]
    e.resources :notification_requests,
      :only => [ :new , :create ],
      :collection => { :get_input_area => :get }
    e.resources :statistics, :only => [ :index ],
      :member => { :visitors => :get , :questionaires => :get }
  end
  
  map.resources :occasions, :except => [ :index ],
    :member => {
    :attendants => :get,
    :report_show => :get,
    :report_create => :post,
    :ticket_availability => :get,
    :cancel => :delete
  } do |oc|
    oc.resources :bookings
  end

  map.resources :bookings, :only => [ :index ], :collection => { :group => :get }

  map.resources :questionaires, :member => {
    :add_template_question => :post,
    :remove_template_question => :delete
  } do |questionaire|
    questionaire.resources :questions, :except => [ :show, :new ]
  end
  map.resources :answers
  map.resources :questions, :except => [ :show, :new ]

  map.resources :categories, :except => [ :show, :new ]
  map.resources :category_groups, :except => [:show, :new ]

  map.resources :districts, :collection => { :select => [ :get, :post ] }
  map.resources :schools, :collection => { :options_list => :get, :select => [ :get, :post ] }
  map.resources :groups, :collection => { :options_list => :get, :select => [ :get, :post ] }
  map.resources :age_groups, :except => [ :show, :index, :new ]

  map.resources :role_applications,
    :except => [ :new ],
    :new => { :booker => :get, :culture_worker => :get },
    :collection => { :archive => :get }


  map.root :controller => "calendar"

  map.calendar 'calendar/:action/:list',
    :controller => 'calendar'

  map.booking 'booking/book/:occasion_id',
    :controller => 'booking', :action => 'book'

  # Questionnaires
  map.answer_questionaire 'questionaires/:answer_form_id/answer',
    :controller => 'answer_form' , :action => 'submit'
  map.question_graph 'questions/:question_id/graph/:occasion_id',
    :controller => 'questions' , :action => 'stat_graph'

  # Role granting
  map.grant_role 'users/:id/grant/:role',
    :controller => 'users', :action => 'grant'
  map.revoke_role 'users/:id/revoke/:role',
    :controller => 'users', :action => 'revoke'
  map.remove_culture_provider_user 'users/:id/remove_culture_provider/:culture_provider_id',
    :controller => 'users', :action => 'remove_culture_provider'

  # LDAP views
  map.ldap 'ldap/',
    :controller => 'ldap', :action => 'index'
  map.ldap_search 'ldap/search',
    :controller => 'ldap', :action => 'search'
  map.ldap_handle 'ldap/handle/:username',
    :controller => 'ldap', :action => 'handle'

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
