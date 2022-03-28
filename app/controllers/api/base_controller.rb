# frozen_string_literal: true

module Api
  class BaseController < ApplicationController
    skip_forgery_protection
    before_action :check_access!

    private 

    # It could be more secure
    def check_access!
      return head :unauthorized if params[:api_key] != Rails.application.credentials.api_key!
    end
  end
end
