# frozen_string_literal: true

class NewUserContract < ApplicationContract
  params do
    required(:email).filled(:string)
    required(:password).filled(:string)
    required(:city).filled(:string)
    required(:role).filled(:string)
  end

  rule(:email).validate(:email_format)
  rule(:password).validate(:password_length)
  rule(:city).validate(:available_city)
  rule(:role).validate(:available_role)
end