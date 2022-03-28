# frozen_string_literal: true

FactoryBot.define do
  factory :push_message do
    title { Faker::Commerce.product_name }
    body { Faker::Marketing.buzzwords }
    city { 'london' }
    creator_id { create(:user, role: 'admin').id }
  end
end