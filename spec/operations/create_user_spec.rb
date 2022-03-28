# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CreateUser do
  include Dry::Monads[:result]

  describe '#call' do
    let(:model) { User }
    subject { described_class.new(model: model) }

    context 'valid params' do
      let(:params) do
        { email: 'test@test.com', password: '12345678', city: 'london', role: 'manager' }
      end

      before do
        allow(model).to receive(:save_if_uniq!).and_return(Success())
      end

      context 'uniq new user' do
        it 'should be success' do
          expect(subject.call(params).success?).to be_truthy
        end
      end
      
      context 'duplicated user' do
        let(:fail_message) { { email: 'error' } } 

        before do
          allow(model).to receive(:save_if_uniq!).and_raise(ErrorWithHashMessage.new(fail_message))
        end

        it 'should be failure' do
          expect(subject.call(params).failure?).to be_truthy
        end

        it 'should return hash error message' do
          expect(subject.call(params).failure).to eq fail_message
        end
      end
    end

    context 'invalid params' do
      context 'email' do
        context 'is not present' do
          let(:params) do
            { password: '12345678', city: 'london', role: 'manager' }
          end

          it 'should be failure' do
            expect(subject.call(params).failure?).to be_truthy
          end

          it 'should return hash error message' do
            expect(subject.call(params).failure[:email].present?).to be_truthy
          end
        end

        context 'is empty' do
          let(:params) do
            { email: '', password: '12345678', city: 'london', role: 'manager' }
          end

          it 'should be failure' do
            expect(subject.call(params).failure?).to be_truthy
          end

          it 'should return hash error message' do
            expect(subject.call(params).failure[:email].present?).to be_truthy
          end
        end

        context 'is wrong format' do
          let(:params) do
            { email: 'hello!', password: '12345678', city: 'london', role: 'manager' }
          end

          it 'should be failure' do
            expect(subject.call(params).failure?).to be_truthy
          end

          it 'should return hash error message' do
            expect(subject.call(params).failure[:email].present?).to be_truthy
          end
        end
      end

      context 'password' do
        context 'is not present' do
          let(:params) do
            { email: 'test@test.com', city: 'london', role: 'manager' }
          end

          it 'should be failure' do
            expect(subject.call(params).failure?).to be_truthy
          end

          it 'should return hash error message' do
            expect(subject.call(params).failure[:password].present?).to be_truthy
          end
        end

        context 'is empty' do
          let(:params) do
            { email: 'test@test.com', password: '', city: 'london', role: 'manager' }
          end

          it 'should be failure' do
            expect(subject.call(params).failure?).to be_truthy
          end

          it 'should return hash error message' do
            expect(subject.call(params).failure[:password].present?).to be_truthy
          end
        end

        context 'is to small' do
          let(:params) do
            { email: 'test@test.com', password: '123', city: 'london', role: 'manager' }
          end

          it 'should be failure' do
            expect(subject.call(params).failure?).to be_truthy
          end

          it 'should return hash error message' do
            expect(subject.call(params).failure[:password].present?).to be_truthy
          end
        end
      end

      context 'city' do
        context 'is not present' do
          let(:params) do
            { email: 'test@test.com',  password: '12345678', role: 'manager' }
          end

          it 'should be failure' do
            expect(subject.call(params).failure?).to be_truthy
          end

          it 'should return hash error message' do
            expect(subject.call(params).failure[:city].present?).to be_truthy
          end
        end

        context 'is empty' do
          let(:params) do
            { email: 'test@test.com', password: '12345678', city: '', role: 'manager' }
          end

          it 'should be failure' do
            expect(subject.call(params).failure?).to be_truthy
          end

          it 'should return hash error message' do
            expect(subject.call(params).failure[:city].present?).to be_truthy
          end
        end

        context 'is unknown value' do
          let(:params) do
            { email: 'test@test.com', password: '12345678', city: 'us', role: 'manager' }
          end

          it 'should be failure' do
            expect(subject.call(params).failure?).to be_truthy
          end

          it 'should return hash error message' do
            expect(subject.call(params).failure[:city].present?).to be_truthy
          end
        end
      end

      context 'role' do
        context 'is not present' do
          let(:params) do
            { email: 'test@test.com',  password: '12345678',  city: 'london' }
          end

          it 'should be failure' do
            expect(subject.call(params).failure?).to be_truthy
          end

          it 'should return hash error message' do
            expect(subject.call(params).failure[:role].present?).to be_truthy
          end
        end

        context 'is empty' do
          let(:params) do
            { email: 'test@test.com', password: '12345678', city: 'london', role: '' }
          end

          it 'should be failure' do
            expect(subject.call(params).failure?).to be_truthy
          end

          it 'should return hash error message' do
            expect(subject.call(params).failure[:role].present?).to be_truthy
          end
        end

        context 'is unknown value' do
          let(:params) do
            { email: 'test@test.com', password: '12345678', city: 'london', role: 'merch' }
          end

          it 'should be failure' do
            expect(subject.call(params).failure?).to be_truthy
          end

          it 'should return hash error message' do
            expect(subject.call(params).failure[:role].present?).to be_truthy
          end
        end
      end
    end
  end  
end