# frozen_string_literal: true

module Web
  class UsersController < Web::BaseController

    def index 
      authorize! :read, User
      @users = User.accessible_by(current_ability, :read).order(:created_at)
    end

    def new 
      authorize! :create, User
      @user = User.new(role: helpers.default_role, city: helpers.default_city)
    end

    def create
      authorize! :create, User
      result = CreateUser.call(params_for_create.to_h)
      send_response(result, users_path, t('.success'), new_user_path)
    end

    def edit 
      authorize_access :update
    end

    def update
      authorize_access :update
      result = UpdateUser.call(params_for_update.to_h)
      send_response(result, users_path, t('.success'), edit_user_path)
    end

    def destroy
      authorize_access :destroy
      result = DeleteUser.call(params_for_delete.to_h)
      send_response(result, users_path, t('.success'), users_path)
    end

    private 

    def authorize_access(action) 
      @user = User.find(params[:id])
      authorize! action, @user
    end

    def send_response(result, success_path, success_message, fail_path)
      if result.success?
        flash[:notice] = success_message
        redirect_to success_path 
      else 
        flash[:alert] = helpers.error_from_hash(result.failure)
        redirect_to fail_path
      end
    end

    def params_for_create
      params
        .require(:user)
        .permit(:email, :password, :role, :city)
    end

    def params_for_update
      params
      .require(:user)
      .permit(:email, :password, :role, :city)
      .tap do |permitted_params|
        permitted_params[:id] = params[:id]
      end
    end

    def params_for_delete
      params.permit(:id)
    end
  end
end