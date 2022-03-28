# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CreatePushMessage do
  include Dry::Monads[:result]

  describe '#call' do
    let(:model) { PushMessage }
    let(:object) { PushMessage.new }
    let(:ability) { FakeAbility.new }
    subject { described_class.new(model: model) }
    
    context 'valid params' do
      let(:params) do
        { title: 'title', body: 'body', city: 'london', creator_id: 1 }
      end
      
      context 'success case' do
        before do
          allow(ability).to receive(:can?).and_return(true)
          allow(model).to receive(:new).and_return(object)
          allow(object).to receive(:save!).and_return(true)
        end

        it 'should be success' do
          expect(subject.call(params, ability).success?).to be_truthy
        end
      end

      context 'user have no rights to create message' do
        before do
          allow(ability).to receive(:can?).and_raise(CanCan::AccessDenied.new('error'))
          allow(model).to receive(:new).and_return(object)
          allow(object).to receive(:save!).and_return(true)
        end

        it 'should be failure' do
          expect(subject.call(params, ability).failure?).to be_truthy
        end

        it 'should return hash error message' do
          expect(subject.call(params, ability).failure).to eq({ push_message: ['error'] })
        end
      end

      context 'saving error' do
        before do
          allow(ability).to receive(:can?).and_return(true)
          allow(model).to receive(:new).and_return(object)
          allow(object).to receive(:save!).and_raise('error')
        end

        it 'should be failure' do
          expect(subject.call(params, ability).failure?).to be_truthy
        end

        it 'should return hash error message' do
          expect(subject.call(params, ability).failure).to eq({ push_message: ['error'] })
        end
      end
    end

    context 'invalid params' do
      context 'title' do
        context 'is not present' do
          let(:params) do
            { body: 'body', city: 'london', creator_id: 1 }
          end

          it 'should be failure' do
            expect(subject.call(params, ability).failure?).to be_truthy
          end

          it 'should return hash error message' do
            expect(subject.call(params, ability).failure[:title].present?).to be_truthy
          end
        end

        context 'is empty' do
          let(:params) do
            { title: '', body: 'body', city: 'london', creator_id: 1 }
          end

          it 'should be failure' do
            expect(subject.call(params, ability).failure?).to be_truthy
          end

          it 'should return hash error message' do
            expect(subject.call(params, ability).failure[:title].present?).to be_truthy
          end
        end

        context 'is wrong length' do
          let(:params) do
            { title: Faker::Lorem.characters(number: 201), email: 'hello!', password: '12345678', city: 'london', role: 'manager' }
          end

          it 'should be failure' do
            expect(subject.call(params, ability).failure?).to be_truthy
          end

          it 'should return hash error message' do
            expect(subject.call(params, ability).failure[:title].present?).to be_truthy
          end
        end
      end

      context 'body' do
        context 'is not present' do
          let(:params) do
            { title: 'title', city: 'london', creator_id: 1 }
          end

          it 'should be failure' do
            expect(subject.call(params, ability).failure?).to be_truthy
          end

          it 'should return hash error message' do
            expect(subject.call(params, ability).failure[:body].present?).to be_truthy
          end
        end

        context 'is empty' do
          let(:params) do
            { title: 'title', body: '', city: 'london', creator_id: 1 }
          end

          it 'should be failure' do
            expect(subject.call(params, ability).failure?).to be_truthy
          end

          it 'should return hash error message' do
            expect(subject.call(params, ability).failure[:body].present?).to be_truthy
          end
        end

        context 'is wrong length' do
          let(:params) do
            { title: 'title', body: Faker::Lorem.characters(number: 401), city: 'london', creator_id: 1 }
          end

          it 'should be failure' do
            expect(subject.call(params, ability).failure?).to be_truthy
          end

          it 'should return hash error message' do
            expect(subject.call(params, ability).failure[:body].present?).to be_truthy
          end
        end
      end

      context 'city' do
        context 'is not present' do
          let(:params) do
            { title: 'title', body: 'body', creator_id: 1 }
          end

          it 'should be failure' do
            expect(subject.call(params, ability).failure?).to be_truthy
          end

          it 'should return hash error message' do
            expect(subject.call(params, ability).failure[:city].present?).to be_truthy
          end
        end

        context 'is empty' do
          let(:params) do
            { title: 'title', body: 'body', city: '', creator_id: 1 }
          end

          it 'should be failure' do
            expect(subject.call(params, ability).failure?).to be_truthy
          end

          it 'should return hash error message' do
            expect(subject.call(params, ability).failure[:city].present?).to be_truthy
          end
        end

        context 'is wrong value' do
          let(:params) do
            { title: 'title', body: 'body', city: 'paris', creator_id: 1 }
          end

          it 'should be failure' do
            expect(subject.call(params, ability).failure?).to be_truthy
          end

          it 'should return hash error message' do
            expect(subject.call(params, ability).failure[:city].present?).to be_truthy
          end
        end
      end
    end
  end
end