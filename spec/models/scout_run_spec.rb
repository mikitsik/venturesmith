# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ScoutRun, type: :model do
  subject(:scout_run) { build(:scout_run) }

  it { is_expected.to belong_to(:user_profile) }
  it { is_expected.to have_many(:opportunities).dependent(:destroy) }
  it { is_expected.to have_many(:evidences).dependent(:destroy) }
  it { is_expected.to have_many(:somnia_requests).dependent(:destroy) }

  it { is_expected.to validate_presence_of(:goal) }
  it { is_expected.to validate_presence_of(:status) }
  it { is_expected.to validate_inclusion_of(:status).in_array(described_class::STATUSES) }

  it { is_expected.to allow_value('').for(:wallet_address) }
  it { is_expected.to allow_value('0x1234567890abcdef1234567890abcdef12345678').for(:wallet_address) }
  it { is_expected.not_to allow_value('0x123').for(:wallet_address) }

  it { is_expected.to allow_value('').for(:tx_hash) }
  it { is_expected.to allow_value("0x#{'a' * 64}").for(:tx_hash) }
  it { is_expected.not_to allow_value('0x123').for(:tx_hash) }

  it { is_expected.to allow_value('').for(:callback_tx_hash) }
  it { is_expected.to allow_value("0x#{'b' * 64}").for(:callback_tx_hash) }
  it { is_expected.not_to allow_value('0x123').for(:callback_tx_hash) }
end
