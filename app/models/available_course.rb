# frozen_string_literal: true

class AvailableCourse < ApplicationRecord
  # search
  include DynamicSearch
  include PgSearch::Model

  pg_search_scope(
    :search,
    associated_against: { course: %i[name code] },
    using:              { tsearch: { prefix: true } }
  )

  # dynamic_search
  search_keys :unit_id, :curriculum_id, :academic_term_id

  # validations
  before_validation :assign_academic_term, on: :create

  # relations
  belongs_to :academic_term
  belongs_to :coordinator, class_name: 'Employee'
  belongs_to :curriculum_course
  belongs_to :curriculum
  belongs_to :unit
  has_many :evaluation_types, class_name: 'CourseEvaluationType', dependent: :destroy
  has_many :groups, class_name: 'AvailableCourseGroup', dependent: :destroy
  has_many :lecturers, through: :groups
  has_many :course_enrollments, dependent: :destroy
  has_one :course, through: :curriculum_course
  accepts_nested_attributes_for :groups, reject_if: :all_blank, allow_destroy: true

  # validations
  validates :assessments_approved, inclusion: { in: [true, false] }
  validates :curriculum_course, uniqueness: { scope: %i[academic_term curriculum] }
  validates :groups, presence: true

  # delegates
  delegate :code,
           :name,
           :theoric,
           :practice,
           :laboratory,
           :credit,
           :program_type,
           :ects,
           :type,
           :curriculum_course_group, to: :curriculum_course
  delegate :name, to: :curriculum, prefix: true
  delegate :name, to: :unit, prefix: true

  # scopes
  scope :without_ids, ->(ids) { where.not(id: ids) }
  scope :compulsories, -> { includes(:curriculum_course).where(curriculum_courses: { type: :compulsory }) }
  scope :electives, -> { includes(:curriculum_course).where(curriculum_courses: { type: :elective }) }

  # custom methods
  def quota_full?
    groups.sum(:quota) == course_enrollments.saved.count
  end

  def enrollable_groups
    groups.order(:name).reject(&:quota_full?)
  end

  private

  def assign_academic_term
    self.academic_term = AcademicTerm.active.last
  end
end
