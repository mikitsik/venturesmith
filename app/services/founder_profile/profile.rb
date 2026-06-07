# frozen_string_literal: true

module FounderProfile
  Profile = Data.define(
    :skills,
    :technologies,
    :domains,
    :available_days,
    :github_url,
    :linkedin_url
  )
end
