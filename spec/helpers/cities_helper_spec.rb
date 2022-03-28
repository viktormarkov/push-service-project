# frozen_string_literal: true

require "spec_helper"

describe CitiesHelper, :type => :helper do
  before do
    allow(helper).to receive(:current_user).and_return(user)
  end

  describe '#cities_for_select' do
    describe 'user is admin' do
      let(:user) { create(:user, role: 'admin') }
      
      it 'should return all counties with localized name and code' do
        expect(helper.cities_for_select).to eq(
          [
            [ 'London', 'london' ],
            [ 'Liverpool', 'liverpool' ]
          ]
        )
      end
    end

    describe 'user is manager' do
      let(:user) { create(:user, role: 'manager', city: 'liverpool') }
      
      it 'should return his own city' do
        expect(helper.cities_for_select).to eq(
          [
            [ 'Liverpool', 'liverpool' ]
          ]
        )
      end
    end
  end

  describe '#default_city' do
    describe 'user is admin' do
      let(:user) { create(:user, role: 'admin') }
      
      it 'should return de' do
        expect(helper.default_city).to eq 'london'
      end
    end

    describe 'user is manager' do
      let(:user) { create(:user, role: 'manager', city: 'liverpool') }
      
      it 'should return his own city' do
        expect(helper.default_city).to eq 'liverpool'
      end
    end
  end
end