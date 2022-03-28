# frozen_string_literal: true

class UpdateUser < ApplicationOperation
  attr_reader :model, :validator

  def initialize(model: User, validator: EditUserContract.new)
    @model = model
    @validator = validator
  end

  def call(params)
    payload = yield validate_params(params)
    user = yield find_user(params[:id])
    payload = prepare_payload(payload.to_h)
    update_user(user, payload)
  end

  private

  def validate_params(payload)
    result = validator.call(payload)
    result.success? ? result : Failure(result.errors.to_h)
  end

  def find_user(id)
    result = Try() { model.find(id) }
    result.success? ? Success(result.value!) : Failure({
      id: [I18n.t('custom.errors.messages.cant_find_user')]
    })
  end

  def prepare_payload(payload)
    payload.except!(:id)
    if payload[:password].present?
      payload[:password_confirmation] = payload[:password]
    else
      payload.except!(:password)
    end
    payload
  end

  def update_user(user, payload)
    result = Try() { user.update(payload) }
    result.success? ? Success() : Failure({ user: [result.exception.message]})
  end
end