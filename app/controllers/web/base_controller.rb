# frozen_string_literal: true

module Web
  class BaseController < ApplicationController
    protect_from_forgery with: :exception, prepend: true
    before_action :authenticate_user!

    rescue_from CanCan::AccessDenied do |exception|
      head :forbidden
    end

    def current_ability
      @current_ability ||= Ability.new(current_user)
    end
  end
end