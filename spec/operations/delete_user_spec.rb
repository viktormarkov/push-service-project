# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DeleteUser do
  include Dry::Monads[:result]

  describe '#call' do
    let(:model) { User }
    subject { described_class.new(model: model) }

    context 'valid params' do
      let(:user) { create(:user) } 

      let(:params) do
        { id: user.id }
      end

      before do
        allow(model).to receive(:find).and_return(user)
        allow(user).to receive(:delete).and_return(true)
      end

      it 'should return success' do
        expect(subject.call(params).success?).to be_truthy
      end

      it 'should call delete' do
        expect(user).to receive(:delete).once
        subject.call(params)
      end
    end

    context 'invalid params' do
      context 'id' do
        context 'is not present' do
          let(:params) do
            {  }
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
            { id: '' }
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
            { id: 123 }
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

        context 'user delete is failed' do
          let(:params) do
            { id: 123 }
          end

          before do
            allow(model).to receive(:find).and_return(model)
            allow(model).to receive(:delete).and_raise('error')
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