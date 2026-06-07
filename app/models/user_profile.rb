# frozen_string_literal: true

class UserProfile < ApplicationRecord
  has_many :somnia_requests, dependent: :destroy
  has_many :scout_runs, dependent: :destroy

  validates :background, presence: true
  validates :available_days, presence: true

  validates :github_url,
            format: URI::DEFAULT_PARSER.make_regexp,
            allow_blank: true

  validates :linkedin_url,
            format: URI::DEFAULT_PARSER.make_regexp,
            allow_blank: true
end
