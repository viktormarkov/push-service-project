# frozen_string_literal: true

module CitiesHelper
  def cities_for_select
    available_cities.map do |city|
      [t("cities.#{city}"), city]
    end
  end

  def default_city
    available_cities.first
  end

  private 

  def available_cities
    if current_user.admin?
      Constants::Cities::ALL
    else
      [current_user.city]
    end
  end
end
