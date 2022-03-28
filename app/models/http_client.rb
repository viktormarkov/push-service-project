# frozen_string_literal: true

require 'faraday'

class HttpClient 
  attr_reader :client

  def initialize(options)
    @client = initialize_client(options)
  end

  def post(path, body)
    client.post(path, body)
  end

  private 

  def initialize_client(options)
    Faraday.new(options) do |connection|
      if Rails.env.test?
        connection.adapter :test, Faraday::Adapter::Test::Stubs.new
      else
        connection.adapter Faraday.default_adapter
      end
    end
  end
end