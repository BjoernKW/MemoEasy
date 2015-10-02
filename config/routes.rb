MemoEasy::Application.routes.draw do
  get 'static_content/contact', :as => 'contact'
  get 'static_content/terms', :as => 'terms'

  authenticated :user do
    get '/' => 'appointments#index'
  end
  get '/' => 'home#index'
  devise_for :users, :controllers => { :registrations => 'registrations' }
  devise_scope :user do
    put 'update_plan', :to => 'registrations#update_plan'
  end
  resources :users

  get 'public(/:id(/:customer_id))', :to => 'appointments#public', :as => 'public'
  get 'appointments/icalendar(/:id(/:staff_member_id))', :to => 'appointments#icalendar', :as => 'icalendar'
  get 'thanks', :to => 'appointments#thanks', :as => 'thanks'
  get 'show_day', :to => 'appointments#show_day', :as => 'show_day'
  post 'receive_text_message', :to => 'receive_text_message#index', :as => 'receive_text_message'

  resources :appointments
  resources :assignments
  resources :companies do
    get 'list_available_days', :on => :collection
  end
  resources :customers do
    get 'customer_link', :on => :member
    get 'send_customer_link', :on => :member
    get 'confirmation', :on => :member
    get 'multiple_new', :on => :collection
  end
  resources :customer_sets
  resources :services
  resources :slots do
    get 'list_available_weekdays', :on => :collection
  end
  resources :staff_members do
    get 'list_available', :on => :collection
    get 'list_available_time_slots', :on => :collection
  end

  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'
end
