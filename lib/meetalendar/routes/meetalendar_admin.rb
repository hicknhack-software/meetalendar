# frozen_string_literal: true

class ActionDispatch::Routing::Mapper

  def comfy_route_meetalendar_admin(options = {})
    options[:path] ||= "admin"
    path = [options[:path], "sites", ":site_id"].join("/")

    scope module: :comfy, as: :comfy do
      scope module: :admin do
        
        namespace :meetalendar, as: :admin_meetalendar, path: path, except: [:show] do
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

end
