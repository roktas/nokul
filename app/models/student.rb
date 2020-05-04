# frozen_string_literal: true

class Student < ApplicationRecord
  # Ldap
  include LDAP::Trigger
  ldap_trigger :user

  # enums
  enum status: {
    active:     1,
    passive:    2,
    disengaged: 3,
    unenrolled: 4,
    graduated:  5
  }

  # relations
  belongs_to :scholarship_type, optional: true
  belongs_to :user
  belongs_to :unit
  belongs_to :stage, class_name: 'StudentGrade', optional: true
  has_one :history, class_name: 'StudentHistory', dependent: :destroy
  has_one :identity, dependent: :destroy
  has_many :calendars, -> { Calendar.active }, through: :unit
  has_many :curriculums, through: :unit
  has_many :semester_registrations, dependent: :destroy
  has_many :course_enrollments, through: :semester_registrations
  has_many :tuition_debts, dependent: :destroy
  accepts_nested_attributes_for :history, allow_destroy: true

  # scopes
  scope :exceeded, -> { where(exceeded_education_period: true) }
  scope :not_scholarships, -> { where(scholarship_type_id: nil) }
  scope :scholarships, -> { where.not(scholarship_type_id: nil) }
  scope :preparations, -> { where(stage: StudentGrade.preparation) }

  # validations
  validates :exceeded_education_period, inclusion: { in: [true, false] }
  validates :unit_id, uniqueness: { scope: %i[user] }
  validates :permanently_registered, inclusion: { in: [true, false] }
  # TODO: Will set equal_to: N, when we decide about student numbers
  validates :student_number, presence: true, uniqueness: true, length: { maximum: 255 }
  validates :semester, numericality: { greater_than: 0 }
  validates :status, inclusion: { in: statuses.keys }
  validates :year, numericality: { greater_than_or_equal_to: 0 }

  # delegations
  delegate :addresses, to: :user
  delegate :name, to: :stage, prefix: true, allow_nil: true
  delegate :name, to: :unit, prefix: true
  delegate :name, to: :scholarship_type, prefix: true, allow_nil: true
  delegate :entrance_type, :graduation_term, :other_studentship, :preparatory_class,
           :registration_date, :registration_term, :graduation_date, to: :history, allow_nil: true

  # background jobs
  after_create_commit :build_identity_information, if: proc { identity.nil? }
  after_create_commit :create_student_history

  # custom methods
  def gpa
    return 0 if semester == 1

    student_number.to_s[-2..].to_f / 25
  end

  def current_registration
    @current_registration ||=
      semester_registrations.find_by(semester: semester) || semester_registrations.create
  end

  def preparation?
    Student.preparations.ids.include?(id)
  end

  def scholarship?
    scholarship_type_id?
  end

  def preparatory_class_repetition?
    preparatory_class.to_i >= 2
  end

  def prospective_student
    user.prospective_students.find_by(unit_id: unit_id)
  end

  private

  def create_student_history
    create_history(
      entrance_type_id:     prospective_student&.student_entrance_type_id,
      registration_date:    created_at,
      registration_term_id: prospective_student&.academic_term_id,
      other_studentship:    !prospective_student&.obs_status
    )
  end

  def build_identity_information
    Kps::IdentitySaveJob.perform_later(user, id)
  end
end
