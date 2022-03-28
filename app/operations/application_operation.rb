# frozen_string_literal: true

class ApplicationOperation
  include Dry::Monads[:result, :do, :try]

  def self.call(*args)
    new.call(*args)
  end
end