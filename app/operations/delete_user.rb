# frozen_string_literal: true

class DeleteUser < ApplicationOperation
  attr_reader :model, :validator

  def initialize(model: User, validator: DeleteUserContract.new)
    @model = model
    @validator = validator
  end

  def call(params)
    payload = yield validate_params(params)
    user = yield find_user(params[:id])
    delete_user(user)
  end

  private

  def validate_params(payload)
    result = validator.call(payload)
    result.success? ? result : Failure(result.errors.to_h)
  end

  def find_user(id)
    result = Try() { model.find(id) }
    result.success? ? Success(result.value!) : Failure({id: [I18n.t('custom.errors.messages.cant_find_user')]})
  end

  def delete_user(user)
    result = Try() { user.delete }
    result.success? ? Success() : Failure({ user: [result.exception.message]})
  end
end