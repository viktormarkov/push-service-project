# frozen_string_literal: true

class CreateAndSendPush < ApplicationOperation
  attr_reader :create_operator, :send_operator

  def initialize(create_operator: CreatePushMessage, send_operator: SendPushMessage)
    @create_operator = create_operator
    @send_operator = send_operator
  end

  def call(params, ability)
    result = create_operator.call(params, ability)
    return failure_result(result, :create) if result.failure?
    # this should be async
    result = send_operator.call(result.value!)
    result.failure? ? failure_result(result, :send) : result
  end

  private

  def failure_result(result, operation)
    Failure(
      failed_operation: operation,
      data: result.failure
    )
  end

end