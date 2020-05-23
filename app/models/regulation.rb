# frozen_string_literal: true

class Regulation < ApplicationRecord
  Extensions::Regulation::Loader.call

  # validates
  validates :class_name, presence: true
  validates :effective_date, presence: true

  # scopes
  scope :active, -> { where.not(repealed_at: nil) }

  # delegates
  delegate :display_name, to: :klass, allow_nil: true

  alias name display_name

  def klass
    class_name.safe_constantize
  end

  def articles
    klass&.articles&.values&.sort || []
  end

  def repealed?
    repealed_at.present?
  end
end
