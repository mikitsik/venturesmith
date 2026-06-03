# frozen_string_literal: true

FactoryBot.define do
  factory :evidence do
    scout_run { nil }
    opportunity { nil }
    source { 'MyString' }
    title { 'MyString' }
    url { 'MyString' }
    summary { 'MyText' }
    signal_type { 'MyString' }
  end
end
