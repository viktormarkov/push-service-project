# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CreateDeviceToken do
  include Dry::Monads[:result]

  describe '#call' do
    let(:model) { DeviceToken }
    subject { described_class.new(model: model) }

    context 'valid params' do
      let(:params) do
        { value: 'token123', city: 'london' }
      end

      before do
        allow(model).to receive(:save_if_uniq!).and_return(Success())
      end

      context 'uniq new token' do
        it 'should be success' do
          expect(subject.call(params).success?).to be_truthy
        end
      end
      
      context 'duplicated token' do
        it 'should be success' do
          expect(subject.call(params).success?).to be_truthy
        end
      end

      context 'error while saving' do
        before do
          allow(model).to receive(:save_if_uniq!).and_raise('error')
        end

        it 'should be failure' do
          expect(subject.call(params).failure?).to be_truthy
        end
      end
    end

    context 'invalid params' do
      context 'without value' do
        let(:params) do
          { city: 'london' }
        end

        it 'should be failure' do
          expect(subject.call(params).failure?).to be_truthy
        end
      end
      
      context 'with empty value' do
        let(:params) do
          { value: '', city: 'london' }
        end

        it 'should be failure' do
          expect(subject.call(params).failure?).to be_truthy
        end
      end
      
      context 'without city' do
        let(:params) do
          { value: 'token123' }
        end

        it 'should be failure' do
          expect(subject.call(params).failure?).to be_truthy
        end
      end
      
      context 'with empty city' do
        let(:params) do
          { value: 'token123', city: '' }
        end

        it 'should be failure' do
          expect(subject.call(params).failure?).to be_truthy
        end
      end
    end
  end  
end