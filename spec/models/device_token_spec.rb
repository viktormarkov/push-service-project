# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DeviceToken, type: :model do
  let(:payload) do
    { value: 'token123', city: 'london' }
  end

  describe '#save_if_uniq!' do
    context 'with uniq value' do
      it 'should return saved token' do
        expect(described_class.save_if_uniq!(payload).class).to eq described_class
      end

      it 'should save token to db' do
        expect { described_class.save_if_uniq!(payload) }.to(
          change { described_class.count }.by(1)
        )
      end
    end

    context 'with duplicated value' do
      before do
        described_class.create(payload)
      end  

      it 'shouldn\'t return saved token' do
        expect(described_class.save_if_uniq!(payload).class).not_to eq described_class
      end

      it 'shouldn\'t save token to db' do
        expect { described_class.save_if_uniq!(payload) }.to(
          change { described_class.count }.by(0)
        )
      end
    end
  end

  describe '#by_city' do
    let!(:token_london) { create(:device_token, city: 'london') }
    let!(:token_liverpool) { create(:device_token, city: 'liverpool') }

    let 'should return tokens from specific city' do
      expect(described_class.by_city('liverpool').count).to eq 1
      expect(described_class.by_city('liverpool').first.id).to eq token_liverpool.id
    end
  end
end
