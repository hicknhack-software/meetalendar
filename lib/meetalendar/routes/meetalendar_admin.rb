# frozen_string_literal: true

class ActionDispatch::Routing::Mapper

  def comfy_route_meetalendar_admin(options = {})
    scope module: 'meetalendar' do
      namespace :admin, path: (options[:path] || "admin") do
        resource :meetalendar, controller: 'meetalendar', only: [:update] do 
          resources :groups, except: [:show, :new]
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
