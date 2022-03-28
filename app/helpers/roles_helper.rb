# frozen_string_literal: true

module RolesHelper
  def roles_for_select
    available_roles.map do |role|
      [t("roles.#{role}"), role]
    end
  end

  def default_role
    available_roles.first
  end

  private 

  def available_roles
    if current_user.admin?
      Constants::Roles::ALL
    else
      [current_user.role]
    end
  end
end
