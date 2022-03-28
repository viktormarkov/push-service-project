# frozen_string_literal: true

class CreateDeviceToken < ApplicationOperation
  attr_reader :model, :validator

  def initialize(model: DeviceToken, validator: NewDeviceTokenContract.new)
    @model = model
    @validator = validator
  end

  def call(params)
    payload = yield validate_params(params)
    save_token(payload.to_h)
  end

  private

  def validate_params(payload)
    validator.call(payload).to_monad
  end

  def save_token(payload)
    Try() { model.save_if_uniq!(payload) }.to_result
  end
end