# frozen_string_literal: true

FactoryBot.define do
  factory :somnia_request do
    association :scout_run

    agent_id { 'scout-agent-v1' }
    request_id { nil }
    status { 'draft' }
    request_tx_hash { nil }
    callback_tx_hash { nil }
    payload { { goal: 'Find startup opportunities' } }
    response { {} }
  end
end
