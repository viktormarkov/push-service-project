# frozen_string_literal: true

class DeviceToken < ApplicationRecord
  scope :save_if_uniq!, -> (payload) do 
    where(value: payload[:value]).exists? || create!(payload)
  end  

  scope :by_city, -> (city) do
    where(city: city)
  end
end
