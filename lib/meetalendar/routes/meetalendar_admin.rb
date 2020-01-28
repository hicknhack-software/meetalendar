# frozen_string_literal: true

class ActionDispatch::Routing::Mapper

  def comfy_route_meetalendar_admin(options = {})
    scope module: 'meetalendar' do
      namespace :admin, path: (options[:path] || "admin") do
        resource :meetalendar, controller: 'home', only: [:show] do
          resources :groups, only: [:create, :edit, :update, :destroy]
          resource :settings, only: [:create, :update]
          namespace :meetup_api do
            resource :search, controller: 'search', only: [:new]
            resource :oauth, controller: 'oauth', only: [:new] do
              get 'callback'
              get 'failure'
            end
          end
          namespace :gcal_api do
            resource :auth, controller: 'auth', only: [:new, :update]
          end
        end
      end
    end
  end

end
