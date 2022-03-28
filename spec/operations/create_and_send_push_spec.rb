# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CreateAndSendPush do
  include Dry::Monads[:result]

  describe '#call' do
    let(:ability) { FakeAbility.new }
    let(:params) { {} }
    let(:create_operator) { CreatePushMessage }
    let(:send_operator) { SendPushMessage }
    let(:push_message) { create(:push_message) }
    subject do 
      described_class.new(create_operator: create_operator, send_operator: send_operator)
        .call(params, ability) 
    end

    context 'success case' do
      before do
        allow(create_operator).to receive(:call).and_return(Success(push_message))
        allow(send_operator).to receive(:call).and_return(Success(push_message))
      end

      it 'should return sucess' do
        expect(subject.success?).to be_truthy
      end

      it 'should return success with push message' do
        expect(subject.value!).to eq push_message
      end
    end
    
    context 'creation failed' do
      let(:fail_message) { { push_message: ['error'] } }

      before do
        allow(create_operator).to receive(:call).and_return(Failure(fail_message))
        allow(send_operator).to receive(:call).and_return(Success(push_message))
      end

      it 'should return failure' do
        expect(subject.failure?).to be_truthy
      end

      it 'should return failure with operation identificator' do
        expect(subject.failure[:failed_operation]).to eq :create
      end

      it 'should return failure with error' do
        expect(subject.failure[:data]).to eq fail_message
      end
    end
    
    context 'sending failed' do
      let(:fail_message) do
        { 
          data: push_message,  
          message: {
            push_message: ['error'] 
          }
        } 
      end

      before do
        allow(create_operator).to receive(:call).and_return(Success(push_message))
        allow(send_operator).to receive(:call).and_return(Failure(fail_message))
      end

      it 'should return failure' do
        expect(subject.failure?).to be_truthy
      end

      it 'should return failure with operation identificator' do
        expect(subject.failure[:failed_operation]).to eq :send
      end

      it 'should return failure with error' do
        expect(subject.failure[:data]).to eq fail_message
      end
    end
  end
end