# frozen_string_literal: true

module Web
  class PushMessagesController < Web::BaseController

    def index
      authorize! :read, PushMessage
      @messages = PushMessage.accessible_by(current_ability).order(created_at: :desc).limit(100)
    end

    def new
      authorize! :create, PushMessage
      @message = PushMessage.new
    end

    def create
      authorize! :create, PushMessage
      result = CreateAndSendPush.call(params_for_create.to_h, current_ability)
      if result.success?
        flash[:notice] = t('.success')
        redirect_to push_message_path(result.value!.id)
      else 
        send_fail_response(result)
      end
    end

    def show
      @message = PushMessage.includes(:creator).find(params[:id])
      authorize! :show, @message
    end

    private 

    def send_fail_response(result)
      flash[:alert] = helpers.error_from_hash(result.failure[:data])
      if result.failure[:failed_operation] == :create
        redirect_to new_push_message_path
      else 
        redirect_to push_message_path(result.failure[:data][:data].id)
      end 
    end

    def params_for_create
      params
        .require(:push_message)
        .permit(:title, :body, :city).tap do |permitted_params|
          permitted_params[:creator_id] = current_user.id
        end
    end
  end
end
