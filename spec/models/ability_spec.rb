# frozen_string_literal: true

require 'rails_helper'

describe 'Ability' do
  let(:ability) { Ability.new(user) }

  let(:user_admin_1) { create(:user, role: 'admin') }
  let(:user_admin_2) { create(:user, role: 'admin') }

  let(:user_manager_1) { create(:user, role: 'manager', city: 'london') }
  let(:user_manager_2) { create(:user, role: 'manager', city: 'liverpool') }

  let(:device_token_1) { create(:device_token, city: 'london') }
  let(:device_token_2) { create(:device_token, city: 'liverpool') }

  let(:push_message_1) { create(:push_message, city: 'london') }
  let(:push_message_2) { create(:push_message, city: 'liverpool') }

  context 'user is admin' do
    let(:user) { user_admin_1 }

    context 'users' do
      it 'should can manage all managers' do
        expect(ability).to be_able_to(:manage, user_manager_1)
        expect(ability).to be_able_to(:manage, user_manager_2)
      end
  
      it 'should can manage admins' do
        expect(ability).to be_able_to(:manage, user_admin_2)
      end
  
      it 'shouldn\'t can destroy themself' do
        expect(ability).not_to be_able_to(:destroy, user)
      end
    end

    context 'expo tokens' do
      it 'should can read all expo tokens' do
        expect(ability).to be_able_to(:read, device_token_1)
        expect(ability).to be_able_to(:read, device_token_2)
      end
    end

    context 'push messages' do
      it 'should can read push messages' do
        expect(ability).to be_able_to(:read, push_message_1)
        expect(ability).to be_able_to(:read, push_message_2)
      end
  
      it 'should can create push messages' do
        expect(ability).to be_able_to(:create, push_message_1)
        expect(ability).to be_able_to(:create, push_message_2)
      end
    end
  end

  context 'user is manager' do
    let(:user) { user_manager_1 }

    context 'users' do
      it 'shouldn\'t can manage managers' do
        expect(ability).not_to be_able_to(:manage, user_manager_2)
      end
  
      it 'shouldn\'t can manage admins' do
        expect(ability).not_to be_able_to(:manage, user_admin_1)
        expect(ability).not_to be_able_to(:manage, user_admin_2)
      end
  
      it 'shouldn\'t can manage themself' do
        expect(ability).not_to be_able_to(:manage, user)
      end
    end

    context 'expo tokens' do
      it 'should can read expo tokens for his city' do
        expect(ability).to be_able_to(:read, device_token_1)
      end

      it 'shouldn\'t can read expo tokens for other cities' do
        expect(ability).not_to be_able_to(:read, device_token_2)
      end
    end

    context 'push messages' do
      it 'should can read push messages from his city' do
        expect(ability).to be_able_to(:read, push_message_1)
      end

      it 'shouldn\'t can read push messages for other cities' do
        expect(ability).not_to be_able_to(:read, push_message_2)
      end
  
      it 'should can create push messages for his city' do
        expect(ability).to be_able_to(:create, push_message_1)
      end

      it 'shouldn\'t can create push messages for other cities' do
        expect(ability).not_to be_able_to(:create, push_message_2)
      end
    end
  end
end