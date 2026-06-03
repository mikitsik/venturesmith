# frozen_string_literal: true

FactoryBot.define do
  factory :opportunity do
    scout_run { nil }
    title { 'MyString' }
    problem { 'MyText' }
    audience { 'MyString' }
    score { 1 }
    build_fit { 1 }
    time_fit { 1 }
    evidence_summary { 'MyText' }
    mvp_plan { 'MyText' }
  end
end
