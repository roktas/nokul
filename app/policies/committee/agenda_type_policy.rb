# frozen_string_literal: true

module Committee
  class AgendaTypePolicy < ApplicationPolicy
    include CrudPolicyMethods

    undef :show?

    private

    def permitted?(*privileges)
      user.privilege? :agenda_management, privileges
    end
  end
end
