# frozen_string_literal: true

require 'pundit_test_case'

module OutcomeManagement
  class UnitStandardPolicyTest < PunditTestCase
    %w[
      create?
      destroy?
      edit?
      index?
      new?
      show?
      update?
    ].each do |method|
      test method do
        assert_permit     users(:serhat)
        assert_not_permit users(:mine)
      end
    end
  end
end
