# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Somnia::OpportunityPassportPayload do
  subject(:payload) { described_class.new(opportunity) }

  let(:user_profile) do
    UserProfile.create!(
      name: 'Aliaksei',
      background: 'Ruby on Rails developer',
      available_days: 30
    )
  end

  let(:scout_run) do
    user_profile.scout_runs.create!(
      goal: 'Find opportunities I can build in 30 days',
      status: 'completed'
    )
  end

  let(:opportunity) do
    scout_run.opportunities.create!(
      title: 'GitHub Issue Triage Copilot',
      problem: 'Maintainers spend too much time on duplicate issues.',
      audience: 'Open-source maintainers',
      score: 91,
      build_fit: 95,
      mvp_plan: ['Import issues', 'Detect duplicates'],
      evidence_summary: 'Repeated GitHub complaints.'
    )
  end

  before do
    scout_run.evidences.create!(
      source: 'github',
      title: 'Duplicate issue triage pain',
      url: 'https://github.com/example/project/issues/123',
      summary: 'Maintainers complain about duplicate issues.',
      signal_type: 'pain'
    )
  end

  describe '#json' do
    subject(:parsed_json) { JSON.parse(payload.json) }

    it 'sets passport kind' do
      expect(parsed_json['kind']).to eq('venture_smith_opportunity_passport')
    end

    it 'includes opportunity title' do
      expect(parsed_json['opportunity']['title']).to eq('GitHub Issue Triage Copilot')
    end

    it 'includes mvp plan as an array' do
      expect(parsed_json['opportunity']['mvp_plan']).to eq(['Import issues', 'Detect duplicates'])
    end

    it 'includes evidence source' do
      expect(parsed_json['evidence'].first['source']).to eq('github')
    end
  end

  it 'builds an Ethereum-compatible metadata hash' do
    expect(payload.metadata_hash).to match(/\A0x[0-9a-f]{64}\z/)
  end

  it 'builds a Rails metadata URI' do
    expect(payload.metadata_uri).to eq("rails://opportunities/#{opportunity.id}")
  end
end
