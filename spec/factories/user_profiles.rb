# frozen_string_literal: true

FactoryBot.define do
  factory :user_profile do
    name { 'Aliaksei Mikitsik' }
    background { 'Ruby/Rails developer focused on AI, PostgreSQL, Hotwire and automation.' }
    available_days { 30 }
    github_url { 'https://github.com/mikitsik' }
    linkedin_url { 'https://www.linkedin.com/in/mikitsik' }
  end
end
