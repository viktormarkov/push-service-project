# frozen_string_literal: true

class User < ApplicationRecord
  default_scope { where(deleted: false) }
  devise :database_authenticatable, :rememberable, :trackable, :timeoutable

  has_many :push_messages

  scope :save_if_uniq!, -> (payload) do 
    if where(email: payload[:email]).exists?
      raise ErrorWithHashMessage.new({ email: [I18n.t('custom.errors.messages.is_not_uniq')] })
    else
      create!(payload)
    end
  end  

  def delete
    update(deleted: true)
  end

  def admin?
    role === Constants::Roles::ADMIN
  end
end
