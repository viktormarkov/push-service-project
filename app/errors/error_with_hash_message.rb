# frozen_string_literal: true

class ErrorWithHashMessage < StandardError
  attr_reader :hash_message

  def initialize(hash_message)
    super(hash_message&.to_s)
    @hash_message = hash_message
  end

  def message
    hash_message
  end
end

