# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExpoPushClient, type: :model do
  include Dry::Monads[:result]

  describe '#send_message' do
    let(:http_client) { FakeHttpClient.new({}) }
    let(:response) { FakeResponse.new }
    let(:push_message) { create(:push_message) }      
    
    let(:token_1) { create(:device_token) }
    let(:token_2) { create(:device_token) }
    let(:token_3) { create(:device_token) }
    let(:push_tokens) { [token_1, token_2, token_3] }

    subject { described_class.new(http_client: http_client) }

    before do
      allow(http_client).to receive(:post).and_return(response)
      allow(response).to receive(:status).and_return(status_code)
      allow(response).to receive(:body).and_return(body)
    end

    context 'successful status code' do
      let(:status_code) { 200 }
      let(:body) do
        [
          { status: 'ok' },
          { status: 'ok'},
          { status: 'ok' }
        ].to_json
      end

      context '3 tokens' do
        it 'should yield successsful result with receipt and tokens' do
          subject.send_message(push_message, push_tokens) do |result, tokens|
            expect(result).to eq Success(JSON.parse(body))
            expect(tokens).to eq push_tokens
          end
        end
      end
      context '120 tokens' do
        let(:push_tokens) { build_list(:device_token, 120) }

        it 'should split requests and yield twice' do
          returned_tokens = []
          yield_times = 0
          subject.send_message(push_message, push_tokens) do |result, tokens|
            returned_tokens << tokens
            yield_times += 1
          end

          expect(returned_tokens.flatten.uniq.length).to eq 120
          expect(yield_times).to eq 2
        end
      end
    end

    context 'not successful status code' do
      let(:status_code) { 400 }
      let(:body) { 'wrong project!' }

      it 'should yield failed result with errors and tokens' do
        subject.send_message(push_message, push_tokens) do |result, tokens|
          expect(result).to eq Failure(status_code.to_s + ': ' + body)
          expect(tokens).to eq push_tokens
        end
      end
    end

    context 'nework error' do
      let(:status_code) { }
      let(:body) {}

      before do
        allow(http_client).to receive(:post).and_raise('network error')
      end

      it 'should yield failed result with errors and tokens' do
        subject.send_message(push_message, push_tokens) do |result, tokens|
          expect(result).to eq Failure('network error')
          expect(tokens).to eq push_tokens
        end
      end
    end
  end
end