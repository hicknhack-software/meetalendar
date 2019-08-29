require 'rubygems'
require 'active_resource'

class Comfy::Admin::Meetalendar::MeetupsController < Comfy::Admin::Cms::BaseController
  before_action :build_meetup_group, only: [:new, :create]
  before_action :load_meetup_group,  only: [:show, :edit, :update, :destroy]

  def index
    @meetups = Comfy::Admin::Meetalendar::MeetupGroup.page(params[:page])
  end

  def search_mask
    render
  end

  def search_result
    search_result = Comfy::Admin::Meetalendar::MeetupsControllerLogic.search_result(params_permit_parameters[:parameters], Time.now)
    @groups_id_name = search_result.groups_id_name
    @found_upcoming_grouped_events = search_result.found_upcoming_grouped_events
    @found_last_grouped_events = search_result.found_last_grouped_events
    @meetup_groups = search_result.meetup_groups
    rescue ::ActiveResource::UnauthorizedAccess => exception
      flash[:error] = "Could not load groups and events from meetup. Is the client authorized to the Meetup API?"
      redirect_to(action: :index) and return
  end

  def authorize_calendar
    @goto_url = Comfy::Admin::Meetalendar::MeetupsCalendarSyncer.get_authorization_url
    key_code = params_permit_key_code[:key_code]
    if !key_code.nil?
      begin
        Comfy::Admin::Meetalendar::MeetupsCalendarSyncer.authorize_and_remember(key_code)
        flash[:success] = "Calendar successfully authorized."
      rescue ::ActiveResource::UnauthorizedAccess => exception
        flash[:error] = exception.message.to_s
      ensure
        (redirect_to(action: :index) and return)
      end
    end
  end

  def authorize_meetup
    redirect_to(Comfy::Admin::Meetalendar::MeetupsControllerLogic::authorize_meetup(request, callback_comfy_admin_meetalendar_meetups_path(@site).to_s)) and return
  end

  def callback
    begin
      Comfy::Admin::Meetalendar::MeetupsControllerLogic::callback(params_permit_code[:code], request, callback_comfy_admin_meetalendar_meetups_path(@site).to_s)
      flash[:success] = "Meetup successfully authorized."
    rescue  ::ActiveResource::ClientError => ex
      flash[:error] = ex.message.to_s
    ensure
      redirect_to(action: :index) and return
    end
  end

  def failure
    # TODO(Schau): Possibly there are arguments given to this function/route containing more info on why meetup api authorization failed.
    flash[:error] = "Meetup authorization failed."
    redirect_to(action: :index) and return
  end

  def create
    @selected_groups_ids = params_permit_selected[:selected_groups_ids]
    if @selected_groups_ids.nil?
      flash[:error] = "Could not create new Meetup subscription(s) as no Meetup groups where selected."
    else
      @selected_groups_ids.each do |selected_id|
        already_present_meetup = Comfy::Admin::Meetalendar::MeetupGroup.where(group_id: selected_id).first

        group_data = params_permit_id(selected_id)

        if group_data.nil?
          flash[:error] = flash[:error].to_s + " + No group data was present for group id: #{selected_id}"
        else
          if already_present_meetup.nil?
            @meetup = Comfy::Admin::Meetalendar::MeetupGroup.new({"group_id": selected_id, "name": group_data[:name], "approved_cities": group_data[:approved_cities], "group_link": group_data[:group_link]})
            @meetup.save!
          else
            already_present_meetup.name = group_data[:name]
            already_present_meetup.approved_cities = group_data[:approved_cities]
            already_present_meetup.group_link = group_data[:group_link]
            already_present_meetup.save!
          end
        end
      end
      # TODO(Schau): Check if this works as intended! flash[:error].blank? instead?
      flash[:success] = "Created or Updated new Meetup Subscription(s)." if flash[:error].nil?
    end
    redirect_to(action: :index) and return
  end

  def edit
    render
  end

  def update
    edited_approved_cities = params_permit_edited_approved_cities[:edited_approved_cities]
    if edited_approved_cities.nil?
      flash[:error] = "New approved cities could not be read. Please try again."
      redirect_to(action: :edit) and return
    else
      @meetup.approved_cities = edited_approved_cities
      @meetup.save!
      flash[:success] = "Edited Meetup Subscription."
      redirect_to(action: :index) and return
    end
  end

  def destroy
    @meetup.destroy
    flash[:success] = 'Meetup deleted'
    redirect_to(action: :index) and return
  end

protected

  def build_meetup_group
    @meetup = Comfy::Admin::Meetalendar::MeetupGroup.new(meetup_params)
  end

  def load_meetup_group
    @meetup = Comfy::Admin::Meetalendar::MeetupGroup.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash.now[:danger] = 'Meetup Group not found'
    redirect_to action: :index
  end

  def meetup_params
    params.fetch(:meetup, {}).permit(:name, :group_id, :approved_cities, :group_link)
  end
  def params_permit_parameters
    params.permit(:parameters)
  end
  def params_permit_selected
    params.permit({selected_groups_ids: []})
  end
  def params_permit_id(selected)
    res = params.require(:groups).permit("#{selected}": [:name, :approved_cities, :group_link])
    res[selected]
  end
  def params_permit_switch
    params.permit(:switch)
  end
  def params_permit_key_code
    params.permit(:key_code)
  end
  def params_permit_code
    params.permit(:code)
  end
  def params_permit_edited_approved_cities
    params.permit(:edited_approved_cities)
  end
end
