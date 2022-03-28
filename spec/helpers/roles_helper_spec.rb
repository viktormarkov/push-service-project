# frozen_string_literal: true

require "spec_helper"

describe RolesHelper, :type => :helper do
  before do
    allow(helper).to receive(:current_user).and_return(user)
  end

  describe '#roles_for_select' do
    describe 'user is admin' do
      let(:user) { create(:user, role: 'admin') }
      
      it 'should return all roles with localized name and code' do
        expect(helper.roles_for_select).to eq(
          [
            [ 'Manager', 'manager' ],
            [ 'Admin', 'admin' ]
          ]
        )
      end
    end

    describe 'user is manager' do
      let(:user) { create(:user, role: 'manager', city: 'liverpool') }
      
      it 'should return his own role' do
        expect(helper.roles_for_select).to eq(
          [
            [ 'Manager', 'manager' ]
          ]
        )
      end
    end
  end

  describe '#default_role' do
    describe 'user is admin' do
      let(:user) { create(:user, role: 'admin') }
      
      it 'should return manager' do
        expect(helper.default_role).to eq 'manager'
      end
    end

    describe 'user is manager' do
      let(:user) { create(:user, role: 'manager', city: 'liverpool') }
      
      it 'should return his own role' do
        expect(helper.default_role).to eq 'manager'
      end
    end
  end
end