# frozen_string_literal: true

class AgendaType < ApplicationRecord
  # search
  include PgSearch
  pg_search_scope(:search, against: :name, using: { tsearch: { prefix: true } })

  # relations
  has_many :agendas, dependent: :nullify

  # validations
  validates :name, presence: true, length: { maximum: 255 }

  # callbacks
  before_save { self.name = name.capitalize_turkish }
end
