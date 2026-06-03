# frozen_string_literal: true

class Evidence < ApplicationRecord
  SOURCES = %w[github hacker_news manual].freeze

  belongs_to :scout_run
  belongs_to :opportunity, optional: true

  validates :source, presence: true, inclusion: { in: SOURCES }
  validates :title, presence: true

  validates :url,
            format: URI::DEFAULT_PARSER.make_regexp,
            allow_blank: true
end
