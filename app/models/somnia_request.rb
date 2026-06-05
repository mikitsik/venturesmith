# frozen_string_literal: true

class SomniaRequest < ApplicationRecord
  STATUSES = %w[draft requested processing completed failed].freeze

  AGENT_KINDS = {
    'json_api_request' => '13174292974160097713',
    'llm_parse_website' => '12875401142070969085',
    'llm_inference' => '12847293847561029384'
  }.freeze

  STAGES = %w[discovery extraction inference].freeze
  TX_HASH_FORMAT = /\A0x[a-fA-F0-9]{64}\z/

  belongs_to :scout_run

  validates :agent_kind, presence: true, inclusion: { in: AGENT_KINDS.keys }
  validates :stage, presence: true, inclusion: { in: STAGES }
  validates :status, presence: true, inclusion: { in: STATUSES }

  validates :request_id, uniqueness: true, allow_blank: true

  validates :request_tx_hash,
            format: { with: TX_HASH_FORMAT },
            allow_blank: true

  validates :callback_tx_hash,
            format: { with: TX_HASH_FORMAT },
            allow_blank: true

  before_validation :set_agent_id_from_kind

  private

  def set_agent_id_from_kind
    self.agent_id = AGENT_KINDS[agent_kind] if agent_kind.present?
  end
end
