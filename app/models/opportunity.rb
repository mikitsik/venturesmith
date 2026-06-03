# frozen_string_literal: true

class Opportunity < ApplicationRecord
  belongs_to :scout_run
  has_many :evidences, dependent: :nullify

  validates :title, presence: true
  validates :problem, presence: true
  validates :score,
            presence: true,
            numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }

  validates :build_fit,
            numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100 },
            allow_nil: true

  validates :time_fit,
            numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100 },
            allow_nil: true
end
