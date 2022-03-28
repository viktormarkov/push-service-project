# frozen_string_literal: true

class NewPushMessageContract < ApplicationContract
  params do
    required(:title).filled(:string)
    required(:body).filled(:string)
    required(:city).filled(:string)
    required(:creator_id).filled(:integer)
  end

  rule(:title).validate(max_string_length: Constants::Validations::MAX_TITLE_SIZE)
  rule(:body).validate(max_string_length: Constants::Validations::MAX_BODY_SIZE)
  rule(:city).validate(:available_city)
end