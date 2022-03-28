# frozen_string_literal: true

class EditUserContract < ApplicationContract
  params do
    required(:id).value(:integer)
    required(:email).filled(:string)
    required(:password).maybe(:string)
    required(:city).filled(:string)
    required(:role).filled(:string)
  end

  rule(:password) do
    min_size = Constants::Validations::MIN_PASSWORD_SIZE
    max_size = Constants::Validations::MAX_PASSWORD_SIZE
    key.failure(:min, min_value: min_size) if value.present? && value.length <= min_size
    key.failure(:max, max_value: max_size) if value.present? && value.length > max_size
  end

  rule(:email).validate(:email_format)
  rule(:city).validate(:available_city)
  rule(:role).validate(:available_role)
end