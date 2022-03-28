# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    case user.role
    when Constants::Roles::ADMIN
      grant_admin_permissions(user)
    when Constants::Roles::MANAGER
      grant_manager_permissions(user)
    end
  end

  private 

  def grant_admin_permissions(user)
    can :manage, User
    cannot :destroy, User, id: user.id
    can :manage, DeviceToken
    can [:read, :create], PushMessage
  end

  def grant_manager_permissions(user)
    can :read, DeviceToken, city: user.city
    can [:read, :create], PushMessage, city: user.city
  end
end
