# frozen_string_literal: true

class PushResult < ApplicationRecord
  enum status: [:waiting, :failed, :successfull]

  belongs_to :push_message
end
