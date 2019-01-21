# frozen_string_literal: true

class HighSchoolType < ApplicationRecord
  include ReferenceValidations
  include ReferenceCallbacks
  include ReferenceSearch

  # relations
  has_many :prospective_students, dependent: :nullify
end
