# frozen_string_literal: true

module Api
  class DeviceTokensController < Api::BaseController
    def create
      if CreateDeviceToken.call(params_for_create.to_h).success?
        head :created 
      else 
        head :bad_request
      end
    end

    private

    def params_for_create
      params.require(:device_token)
        .permit(:value, :city)
    end
  end
end
