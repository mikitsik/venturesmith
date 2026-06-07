# frozen_string_literal: true

class SomniaRequest < ApplicationRecord
  AGENT_IDS = {
    'json_api_request' => '13174292974160097713',
    'llm_inference' => '12847293847561029384'
  }.freeze

  STATUSES = %w[draft requested processing completed failed].freeze

  belongs_to :scout_run, optional: true
  belongs_to :user_profile, optional: true

  validates :agent_kind, presence: true, inclusion: { in: AGENT_IDS.keys }
  validates :stage, presence: true
  validates :status, presence: true, inclusion: { in: STATUSES }

  validates :payload, :response, comparison: { other_than: nil }

  validates :request_tx_hash,
            format: { with: /\A0x[a-fA-F0-9]{64}\z/ },
            allow_blank: true

  validates :callback_tx_hash,
            format: { with: /\A0x[a-fA-F0-9]{64}\z/ },
            allow_blank: true

  validate :exactly_one_parent?

  before_validation :set_agent_id

  private

  def set_agent_id
    self.agent_id = AGENT_IDS[agent_kind] if agent_kind.present?
  end

  def exactly_one_parent?
    return false if user_profile.present? ^ scout_run.present?

    errors.add(:base, 'SomniaRequest must belong to either UserProfile or ScoutRun')
  end
end
