# frozen_string_literal: true

class NewDeviceTokenContract < ApplicationContract
  params do
    required(:value).filled(:string)
    required(:city).filled(:string)
  end

  rule(:city).validate(:available_city)
end