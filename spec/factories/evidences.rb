# frozen_string_literal: true

FactoryBot.define do
  factory :evidence do
    association :scout_run

    opportunity { nil }
    source { 'github' }
    title { 'Users ask for better documentation search' }
    url { 'https://github.com/example/project/issues/1' }
    summary { 'Issue thread shows repeated demand for better documentation discovery.' }
    signal_type { 'feature_request' }
  end
end
