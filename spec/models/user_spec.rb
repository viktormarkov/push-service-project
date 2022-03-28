# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe '#admin?' do
    context 'user is admin' do
      let (:subject) { create(:user, role: 'admin') }

      it 'should return true' do
        expect(subject.admin?).to be_truthy
      end
    end

    context 'user is manager' do
      let (:subject) { create(:user, role: 'manager') }

      it 'should return false' do
        expect(subject.admin?).to be_falsy
      end
    end
  end

  describe '#save_if_uniq!' do
    let(:payload) do
      { email: 'test@test.com', password: '12345678', city: 'london', role: 'manager' }
    end

    context 'with uniq value' do
      it 'should save user to db' do
        expect { described_class.save_if_uniq!(payload) }.to(
          change { described_class.count }.by(1)
        )
      end
    end

    context 'with duplicated value' do
      before do
        described_class.create(payload)
      end  

      it 'shouldn\'t save user to db' do
        suppress(Exception) do
          expect { described_class.save_if_uniq!(payload) }.to(
            change { described_class.count }.by(0)
          )
       end
      end

      it 'should raise exception' do
        expect { described_class.save_if_uniq!(payload) }.to raise_exception ErrorWithHashMessage
      end

      context 'duplicated user already deleted' do
        before do
          User.find_by_email(payload[:email]).update(deleted: true)
        end

        it 'should save user to db' do
          expect { described_class.save_if_uniq!(payload) }.to(
            change { described_class.count }.by(1)
          )
        end
      end
    end
  end

  describe '#delete' do
    subject { create(:user, role: 'admin', email: 'test@test.com') }

    it 'should be updated in db with deleted flag' do
      subject.delete
      expect(described_class.unscoped.where(email: subject.email, deleted: true).exists?).to be_truthy
    end
  end
end
