# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Somnia::GithubProfilePipeline do
  subject(:pipeline) { described_class.new(user_profile) }

  let(:user_profile) do
    UserProfile.create!(
      background: 'Ruby on Rails developer. PostgreSQL, Hotwire, Docker.',
      available_days: 30,
      github_url: 'https://github.com/mikitsik'
    )
  end

  describe '#start!' do
    subject(:request) { pipeline.start! }

    it 'creates GitHub discovery request' do
      expect(request.stage).to eq('github_discovery')
    end

    it 'uses JSON API Request agent' do
      expect(request.agent_kind).to eq('json_api_request')
    end

    it 'sets Somnia JSON API agent id' do
      expect(request.agent_id).to eq('13174292974160097713')
    end

    it 'builds GitHub API payload' do
      expect(request.payload['username']).to eq('mikitsik')
    end

    it 'attaches request to user profile' do
      expect(request.user_profile).to eq(user_profile)
    end
  end

  describe '#build_inference_request!' do
    subject(:request) { pipeline.build_inference_request!(github_request) }

    let(:github_request) do
      pipeline.start!.tap do |request|
        request.update!(
          status: 'completed',
          response: {
            user: { login: 'mikitsik' },
            repos: [{ name: 'venture_smith', language: 'Ruby' }]
          }
        )
      end
    end

    it 'creates founder profile inference request' do
      expect(request.stage).to eq('founder_profile_inference')
    end

    it 'uses LLM inference agent' do
      expect(request.agent_kind).to eq('llm_inference')
    end

    it 'sets Somnia LLM inference agent id' do
      expect(request.agent_id).to eq('12847293847561029384')
    end

    it 'includes founder background' do
      expect(request.payload['founder_input']['background']).to include('Ruby on Rails')
    end

    it 'includes GitHub response' do
      expect(request.payload['github_response']['repos'].first['name']).to eq('venture_smith')
    end
  end
end
