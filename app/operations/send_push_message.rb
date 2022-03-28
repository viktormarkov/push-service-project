# frozen_string_literal: true

class SendPushMessage < ApplicationOperation
  attr_reader :sender, :token_model, :push_result_model

  def initialize(sender: ExpoPushClient, token_model: DeviceToken, push_result_model: PushResult)
    @sender = ExpoPushClient
    @token_model = token_model
    @push_result_model = push_result_model
  end

  def call(push_message)
    push_results = send_push_message(push_message)
    save_final_result(push_message, push_results)
  end

  private

  def send_push_message(push_message)
    tokens = device_tokens(push_message.city)
    push_results = []
    sender.send_message(push_message, tokens) do |result, recepient_tokens|
      push_results << create_push_result(push_message, result, recepient_tokens)
    end
    push_results
  end

  def create_push_result(push_message, request_result, recepient_tokens)
    push_result = push_result_model.new(
      push_message_id: push_message.id,
      recepient_token_ids: recepient_tokens.pluck(:id)
    )
    if request_result.success?
      push_result.status_tickets = request_result.value!
      push_result.status = :successfull
    else  
      push_result.status = :failed
      push_result.error = request_result.failure
    end

    push_result.save!
    push_result
  end

  def push_message_status(push_results)
    final_status = push_results.map(&:status).uniq
    if final_status.length == 0
      :successfull
    elsif final_status.length > 1
      :partially_sent
    else 
      final_status.first
    end
  end

  def save_final_result(push_message, push_results)
    push_message.update!(status: push_message_status(push_results))
    if push_message.successfull?
      Success(push_message)
    else  
      Failure(
        data: push_message,
        message: {
          push_message: push_results.select{|res| res.error.present? }.map(&:error) 
        }
      )
    end
  end

  def device_tokens(city)
    token_model.by_city(city)
  end
end