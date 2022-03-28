# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SendPushMessage do
  include Dry::Monads[:result]

  describe '#call' do
    let(:token_model) { DeviceToken }
    let(:push_result_model) { PushResult }
    let(:push_result_object) { PushResult.new }
    let(:sender) { ExpoPushClient }

    let(:push_message) { create(:push_message) }
    let(:push_tokens) { create_list(:device_token, 3, city: push_message.city)}
    subject { described_class.new(sender: sender, token_model: token_model, push_result_model: push_result_model) }

    before do
      allow(token_model).to receive(:by_city).and_return(push_tokens)
      allow(push_result_model).to receive(:new).and_return(push_result_object)
      allow(push_result_object).to receive(:save!).and_return(push_result_model)
    end

    context 'success' do
      before do
        allow(sender).to receive(:send_message).and_yield(Success(values: {}), push_tokens)
      end

      it 'should return success with push message' do
        expect(subject.call(push_message).value!).to eq push_message
      end

      it 'push message should have successufull status' do
        expect(subject.call(push_message).value!.successfull?).to be_truthy
      end

      it 'push_result should be created with all args' do
        expect(push_result_model).to receive(:new)
          .with(push_message_id: push_message.id, recepient_token_ids: push_tokens.pluck(:id))
          .once

        expect(push_result_object).to receive(:status_tickets=)
          .with({values: {}})
          .once

        expect(push_result_object).to receive(:status=)
          .with(:successfull)
          .once

        expect(push_result_object).to receive(:save!)
          .once

        subject.call(push_message)
      end
    end

    context 'fail' do
      before do
        allow(sender).to receive(:send_message).and_yield(Failure(400), push_tokens)
      end

      it 'should return failure with push message and error' do
        expect(subject.call(push_message).failure[:data]).to eq push_message
        expect(subject.call(push_message).failure[:message][:push_message]).to eq ['400']
      end

      it 'push message should have failed status' do
        expect(subject.call(push_message).failure[:data].failed?).to be_truthy
      end

      it 'push_result should be created with all args' do
        expect(push_result_model).to receive(:new)
          .with(push_message_id: push_message.id, recepient_token_ids: push_tokens.pluck(:id))
          .once

        expect(push_result_object).to receive(:status=)
          .with(:failed)
          .once

        expect(push_result_object).to receive(:error=)
          .with(400)
          .once

        expect(push_result_object).to receive(:save!)
          .once

        subject.call(push_message)
      end
    end

    context 'partially sent' do
      before do
        allow(sender).to receive(:send_message)
          .and_yield(Failure(400), push_tokens)
          .and_yield(Success(values: {}), push_tokens)

        allow(push_result_model).to receive(:new).and_call_original
        allow(push_result_object).to receive(:save!).and_call_original
      end

      it 'should return failure with push message and error' do
        expect(subject.call(push_message).failure[:data]).to eq push_message
        expect(subject.call(push_message).failure[:message][:push_message]).to eq ['400']
      end

      it 'push message should have partially_sent status' do
        expect(subject.call(push_message).failure[:data].partially_sent?).to be_truthy
      end
    end
  end
end