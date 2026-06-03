# frozen_string_literal: true

FactoryBot.define do
  factory :opportunity do
    association :scout_run

    title { 'AI Documentation Search' }
    problem { 'Developers struggle to find accurate answers across fragmented documentation.' }
    audience { 'Developer tool builders' }
    score { 91 }
    build_fit { 90 }
    time_fit { 85 }
    evidence_summary { 'Repeated complaints in GitHub issues and Hacker News discussions.' }
    mvp_plan { 'Build crawler, index docs, add semantic search, ship hosted MVP.' }
  end
end
