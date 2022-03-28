# frozen_string_literal: true

FactoryBot.define do
  factory :device_token do
    value { Faker::Alphanumeric.alpha(number: 10) }
    city { 'london' }
  end
end