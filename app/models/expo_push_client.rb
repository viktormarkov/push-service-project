# frozen_string_literal: true

class ExpoPushClient
  include Dry::Monads[:result]

  attr_reader :http_client

  def initialize(http_client: HttpClient.new(request_options))
    @http_client = http_client
  end

  def self.send_message(message, tokens, &block)
    new.send_message(message, tokens, &block)
  end

  def send_message(message, tokens)
    slice_tokens(tokens).each do |tokens|
      yield send_sliced_part(message, tokens), tokens
    end
  end

  private 

  def send_sliced_part(message, tokens)
    begin
      request_body = request_body(message, tokens)
      response = http_client.post('/--/api/v2/push/send', request_body)
      process_response(response)
    rescue => e
      Failure(e.message)
    end
  end

  def process_response(response)
    if response.status >= 200 && response.status < 300
      Success(JSON.parse(response.body))
    else  
      Failure(response.status.to_s + ': ' + response.body.to_s)
    end
  end

  def slice_tokens(tokens)
    sliced_tokens = []
    tokens.each_slice(99) do |values|
      sliced_tokens << values
    end
    sliced_tokens
  end

  def request_body(message, tokens)
    JSON[{
      to: tokens.pluck(:value),
      title: message.title, 
      body: message.body
    }]
  end

  def request_options
    {
      url: 'https://exp.host',
      headers: {
        'Content-Type' => 'application/json; charset=utf-8',
        'Accept' => 'application/json',
        'Authorization' => "Bearer #{Rails.application.credentials.expo_access_token!}"
      }, 
      request: { timeout: 20 }
    }
  end
end