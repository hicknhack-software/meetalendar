module Meetalendar
  class Admin::GroupsController < Comfy::Admin::Cms::BaseController
    before_action :find_group, only: %i[show edit update destroy]

    def edit
    end

    def create
      create_params.values.each do |group_params|
        next unless group_params[:selected]
        attr_params = group_params[:attr]
        Group.find_or_initialize_by(meetup_id: attr_params[:id]).update!(create_attributes(attr_params))
      end
      flash[:success] = "Created or Updated new Group Subscription(s)."
      redirect_to :admin_meetalendar
    end

    def update
      @group.update! update_params
      flash[:success] = 'Group updated'
      redirect_to action: :index
    rescue ActiveRecord::RecordInvalid
      flash.now[:danger] = 'Failed to update Group'
      render action: :edit
    end

    def destroy
      @group.destroy
      flash[:success] = 'Group deleted'
      redirect_to :admin_meetalendar
    end

    protected

    def find_group
      @group = Group.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash.now[:danger] = 'Group not found'
      redirect_to :admin_meetalendar
    end

    def create_attributes(attr)
      attr.to_h.symbolize_keys.transform_keys do |key|
        {id: :meetup_id, link: :meetup_link, cities: :approved_cities}.fetch(key, key)
      end
    end

    def create_params
      params.permit(groups: [:selected, {attr: [:id, :name, :link, :cities]}]).require(:groups)
    end

    def update_params
      params.fetch(:group, {}).permit(:approved_cities)
    end
  end
end
