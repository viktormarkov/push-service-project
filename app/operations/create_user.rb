# frozen_string_literal: true

class CreateUser < ApplicationOperation
  attr_reader :model, :validator

  def initialize(model: User, validator: NewUserContract.new)
    @model = model
    @validator = validator
  end

  def call(params)
    payload = yield validate_params(params)
    save_user(payload.to_h)
  end

  private

  def validate_params(payload)
    result = validator.call(payload)
    result.success? ? result : Failure(result.errors.to_h)
  end

  def save_user(payload)
    result = Try() { model.save_if_uniq!(payload) }
    result.success? ? Success() : Failure(result.exception.message)
  end
end