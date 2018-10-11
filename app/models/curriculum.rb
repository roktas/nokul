# frozen_string_literal: true

class Curriculum < ApplicationRecord
  # search
  include PgSearch
  include DynamicSearch

  MAX_NUMBER_OF_SEMESTERS = 12

  pg_search_scope(
    :search,
    against: %i[name],
    using: { tsearch: { prefix: true } }
  )

  # dynamic_search
  search_keys :unit_id, :status

  # relations
  belongs_to :unit
  has_many :unit_curriculums, dependent: :destroy
  has_many :programs, through: :unit_curriculums, source: :unit

  # validations
  validates :name, presence: true, uniqueness: { scope: :unit_id }
  validates :number_of_semesters, numericality: {
    greater_than: 0, less_than_or_equal_to: MAX_NUMBER_OF_SEMESTERS
  }
  validates :status, presence: true

  # enumerations
  enum status: { passive: 0, active: 1 }
end
