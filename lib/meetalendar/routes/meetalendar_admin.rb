# frozen_string_literal: true

class ActionDispatch::Routing::Mapper

  def comfy_route_meetalendar_admin(options = {})
    scope module: 'meetalendar', as: 'meetalendar' do
      namespace :admin, path: (options[:path] || "admin") do
        resources :meetups, except: [:show] do
          collection do
            get 'search_mask'
            get 'search_result'
            get  'authorize_calendar'
            post 'authorize_calendar'
            get 'authorize_meetup'
            get 'callback'
            get 'failure'
          end
        end
      end
    end
  end

end
