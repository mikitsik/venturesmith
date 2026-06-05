# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SomniaRequest, type: :model do
  subject(:somnia_request) { build(:somnia_request) }

  it { is_expected.to belong_to(:scout_run) }

  it { is_expected.to validate_presence_of(:status) }
  it { is_expected.to validate_inclusion_of(:status).in_array(described_class::STATUSES) }

  it { is_expected.to allow_value('').for(:request_tx_hash) }
  it { is_expected.to allow_value("0x#{'a' * 64}").for(:request_tx_hash) }
  it { is_expected.not_to allow_value('0x123').for(:request_tx_hash) }

  it { is_expected.to allow_value('').for(:callback_tx_hash) }
  it { is_expected.to allow_value("0x#{'b' * 64}").for(:callback_tx_hash) }
  it { is_expected.not_to allow_value('0x123').for(:callback_tx_hash) }
end
