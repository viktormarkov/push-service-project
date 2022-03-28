# frozen_string_literal: true

class CreatePushMessage < ApplicationOperation
  attr_reader :model, :validator

  def initialize(model: PushMessage, validator: NewPushMessageContract.new)
    @model = model
    @validator = validator
  end

  def call(params, ability)
    payload = yield validate_params(params)
    message = build_message(payload.to_h)
    yield authorize_access(message, ability)
    save_message(message)
  end

  private

  def validate_params(payload)
    result = validator.call(payload)
    result.success? ? result : Failure(result.errors.to_h)
  end

  def build_message(payload)
    model.new(payload)
  end

  def authorize_access(message, ability)
    result = Try() { ability.can? :create, message }
    result.success? ? Success() : Failure({ push_message: [result.exception.message]})
  end

  def save_message(message)
    result = Try() { message.save! }
    result.success? ? Success(message) : Failure({ push_message: [result.exception.message]})
  end
end