# frozen_string_literal: true

module Somnia
  class GithubProfilePipeline
    GITHUB_API_BASE = 'https://api.github.com'

    attr_reader :user_profile

    def initialize(user_profile)
      @user_profile = user_profile
    end

    def start!
      user_profile.somnia_requests.create!(
        agent_kind: 'json_api_request',
        stage: 'github_discovery',
        status: 'draft',
        payload: github_discovery_payload,
        response: initial_response
      )
    end

    def build_inference_request!(github_request)
      raise ArgumentError, 'GitHub request is not completed' unless github_request.status == 'completed'

      user_profile.somnia_requests.create!(
        agent_kind: 'llm_inference',
        stage: 'founder_profile_inference',
        status: 'draft',
        payload: inference_payload(github_request),
        response: initial_response
      )
    end

    private

    def initial_response
      { data: [] }
    end

    def github_discovery_payload
      {
        purpose: 'Fetch public GitHub data to build founder profile.',
        source: 'github',
        username: github_username,
        requests: [
          {
            name: 'user',
            url: "#{GITHUB_API_BASE}/users/#{github_username}"
          },
          {
            name: 'repos',
            url: "#{GITHUB_API_BASE}/users/#{github_username}/repos?per_page=30&sort=updated"
          }
        ]
      }
    end

    def inference_payload(github_request)
      {
        purpose: 'Build normalized founder profile from user background and GitHub data.',
        expected_output: {
          skills: [],
          technologies: [],
          domains: [],
          experience_summary: '',
          builder_type: ''
        },
        founder_input: {
          background: user_profile.background,
          available_days: user_profile.available_days,
          github_url: user_profile.github_url
        },
        github_response: github_request.response
      }
    end

    def github_username
      URI.parse(user_profile.github_url).path.split('/').compact_blank.first
    end
  end
end
