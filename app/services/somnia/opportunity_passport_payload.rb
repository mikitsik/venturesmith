# frozen_string_literal: true

require 'eth'
require 'json'

module Somnia
  class OpportunityPassportPayload
    attr_reader :opportunity

    def initialize(opportunity)
      @opportunity = opportunity
    end

    def json
      JSON.generate(payload)
    end

    def metadata_hash
      "0x#{Eth::Util.keccak256(json).unpack1('H*')}"
    end

    def metadata_uri
      "rails://opportunities/#{opportunity.id}"
    end

    def payload
      {
        version: 1,
        kind: 'venture_smith_opportunity_passport',
        opportunity: opportunity_payload,
        scout_run: scout_run_payload,
        founder_profile: founder_profile_payload,
        evidence: evidence_payload,
        created_at: opportunity.created_at&.iso8601
      }
    end

    private

    def opportunity_payload
      {
        id: opportunity.id,
        title: opportunity.title,
        problem: opportunity.problem,
        audience: opportunity.audience,
        score: opportunity.score,
        build_fit: opportunity.build_fit,
        mvp_plan: opportunity.mvp_plan,
        evidence_summary: opportunity.evidence_summary
      }
    end

    def scout_run
      opportunity.scout_run
    end

    def user_profile
      scout_run.user_profile
    end

    def scout_run_payload
      {
        id: scout_run.id,
        goal: scout_run.goal,
        status: scout_run.status
      }
    end

    def founder_profile_payload
      {
        id: user_profile.id,
        name: user_profile.name,
        background: user_profile.background,
        available_days: user_profile.available_days,
        github_url: user_profile.github_url,
        linkedin_url: user_profile.linkedin_url
      }
    end

    def evidence_payload
      scout_run.evidences.map do |evidence|
        {
          id: evidence.id,
          source: evidence.source,
          title: evidence.title,
          url: evidence.url,
          summary: evidence.summary,
          signal_type: evidence.signal_type
        }
      end
    end
  end
end
