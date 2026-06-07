# frozen_string_literal: true

FactoryBot.define do
  factory :founder_profile_run do
    user_profile { nil }
    status { 'MyString' }
    source { 'MyString' }
    profile_data { '' }
    error_message { 'MyText' }
  end
end
