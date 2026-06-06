# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Somnia::OpportunityPassportMinter do
  subject(:minter) { described_class.new(opportunity) }

  let(:opportunity) do
    user_profile = UserProfile.create!(
      background: 'Ruby on Rails developer',
      available_days: 30
    )

    scout_run = user_profile.scout_runs.create!(
      goal: 'Find opportunities',
      status: 'completed'
    )

    scout_run.opportunities.create!(
      title: 'GitHub Issue Triage Copilot',
      problem: 'Duplicate issues waste maintainer time.',
      audience: 'Open-source maintainers',
      score: 91,
      build_fit: 95,
      mvp_plan: ['Import issues'],
      evidence_summary: 'GitHub issues show repeated pain.'
    )
  end
  let(:script_result) do
    {
      tx_hash: '0xabc',
      passport_id: '7',
      metadata_hash: '0xhash',
      metadata_uri: 'rails://opportunities/1'
    }.to_json
  end

  before do
    allow(Open3).to receive(:capture3).and_return(
      [
        "noise\n#{script_result}\n",
        '',
        instance_double(Process::Status, success?: true)
      ]
    )

    minter.mint!
    opportunity.reload
  end

  it 'stores passport id' do
    expect(opportunity.passport_id).to eq('7')
  end

  it 'stores passport transaction hash' do
    expect(opportunity.passport_tx_hash).to eq('0xabc')
  end

  it 'stores passport metadata hash' do
    expect(opportunity.passport_metadata_hash).to eq('0xhash')
  end

  it 'stores passport metadata uri' do
    expect(opportunity.passport_metadata_uri).to eq('rails://opportunities/1')
  end
end
