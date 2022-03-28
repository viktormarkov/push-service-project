# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UpdateUser do
  include Dry::Monads[:result]
  
  describe '#call' do
    let(:model) { User }
    subject { described_class.new(model: model) }

    context 'valid params' do
      let(:user) { create(:user) } 

      let(:params) do
        { email: 'test@test.com', password: '', city: 'london', role: 'admin', id: user.id }
      end

      before do
        allow(model).to receive(:find).and_return(user)
        allow(user).to receive(:update).and_return(user)
      end

      context 'without password' do
        it 'should return success' do
          expect(subject.call(params).success?).to be_truthy
        end

        it 'should call update' do
          expect(user).to receive(:update)
            .with({ email: 'test@test.com', city: 'london', role: 'admin'})
            .once
          subject.call(params)
        end
      end

      context 'with password' do
        before { params[:password] = '12345678' }

        it 'should return success' do
          expect(subject.call(params).success?).to be_truthy
        end

        it 'should call update' do
          expect(user).to receive(:update)
            .with({ email: 'test@test.com', password: '12345678', password_confirmation: '12345678', city: 'london', role: 'admin'})
            .once
          subject.call(params)
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
            { email: 'test@test.com', password: '12345678', city: 'paris', role: 'manager' }
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

      context 'id' do
        context 'is not present' do
          let(:params) do
            { email: 'test@test.com',  password: '12345678',  city: 'london', role: 'admin' }
          end

          it 'should be failure' do
            expect(subject.call(params).failure?).to be_truthy
          end

          it 'should return hash error message' do
            expect(subject.call(params).failure[:id].present?).to be_truthy
          end
        end

        context 'is empty' do
          let(:params) do
            { id: '', email: 'test@test.com', password: '12345678', city: 'london', role: 'admin' }
          end

          it 'should be failure' do
            expect(subject.call(params).failure?).to be_truthy
          end

          it 'should return hash error message' do
            expect(subject.call(params).failure[:id].present?).to be_truthy
          end
        end

        context 'user not found' do
          let(:params) do
            { id: User.last&.id.to_i + 1000, email: 'test@test.com', password: '12345678', city: 'london', role: 'admin' }
          end

          before do
            allow(model).to receive(:find).and_raise(ActiveRecord::RecordNotFound)
          end

          it 'should be failure' do
            expect(subject.call(params).failure?).to be_truthy
          end

          it 'should return hash error message' do
            expect(subject.call(params).failure[:id].present?).to be_truthy
          end
        end

        context 'user update is failed' do
          let(:params) do
            { id: 123, email: 'test@test.com', password: '12345678', city: 'london', role: 'admin' }
          end

          before do
            allow(model).to receive(:find).and_return(model)
            allow(model).to receive(:update).and_raise('error')
          end

          it 'should be failure' do
            expect(subject.call(params).failure?).to be_truthy
          end

          it 'should return hash error message' do
            expect(subject.call(params).failure[:user].present?).to be_truthy
          end
        end
      end
    end
  end  
end