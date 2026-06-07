# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SomniaRequest, type: :model do
  subject(:somnia_request) do
    described_class.new(
      user_profile:,
      agent_kind: 'json_api_request',
      stage: 'github_discovery',
      status: 'draft',
      payload: { requests: [] },
      response: { data: [] }
    )
  end

  let(:user_profile) do
    UserProfile.create!(
      background: 'Ruby on Rails developer',
      available_days: 30
    )
  end

  let(:scout_run) do
    user_profile.scout_runs.create!(
      goal: 'Find opportunities',
      status: 'draft'
    )
  end

  it { is_expected.to belong_to(:scout_run).optional }
  it { is_expected.to belong_to(:user_profile).optional }

  it { is_expected.to validate_presence_of(:status) }
  it { is_expected.to validate_inclusion_of(:status).in_array(described_class::STATUSES) }

  it { is_expected.to allow_value('').for(:request_tx_hash) }
  it { is_expected.to allow_value("0x#{'a' * 64}").for(:request_tx_hash) }
  it { is_expected.not_to allow_value('0x123').for(:request_tx_hash) }

  it { is_expected.to allow_value('').for(:callback_tx_hash) }
  it { is_expected.to allow_value("0x#{'b' * 64}").for(:callback_tx_hash) }
  it { is_expected.not_to allow_value('0x123').for(:callback_tx_hash) }

  it 'allows user profile parent' do
    expect(somnia_request).to be_valid
  end

  it 'requires exactly one parent' do
    somnia_request.user_profile = nil

    expect(somnia_request).not_to be_valid
  end

  it 'does not allow both parents' do
    somnia_request.scout_run = scout_run

    expect(somnia_request).not_to be_valid
  end
end
