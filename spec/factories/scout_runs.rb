# frozen_string_literal: true

FactoryBot.define do
  factory :scout_run do
    association :user_profile

    goal { 'Find startup opportunities I can build in 30 days.' }
    status { 'draft' }
    wallet_address { '0x1234567890abcdef1234567890abcdef12345678' }
    somnia_request_id { nil }
    tx_hash { nil }
    callback_tx_hash { nil }
    result_hash { nil }
  end
end
