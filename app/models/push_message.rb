# frozen_string_literal: true

class PushMessage < ApplicationRecord
  enum status: [:waiting, :failed, :partially_sent, :successfull]

  belongs_to :creator,  -> { where(deleted: [true, false]) }, class_name: 'User'
  has_many :push_results
end
