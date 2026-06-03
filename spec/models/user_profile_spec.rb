# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserProfile, type: :model do
  subject(:user_profile) { build(:user_profile) }

  it { is_expected.to have_many(:scout_runs).dependent(:destroy) }

  it { is_expected.to validate_presence_of(:background) }
  it { is_expected.to validate_presence_of(:available_days) }

  it { is_expected.to allow_value('').for(:github_url) }
  it { is_expected.to allow_value('https://github.com/mikitsik').for(:github_url) }
  it { is_expected.not_to allow_value('not-a-url').for(:github_url) }

  it { is_expected.to allow_value('').for(:linkedin_url) }
  it { is_expected.to allow_value('https://www.linkedin.com/in/example').for(:linkedin_url) }
  it { is_expected.not_to allow_value('not-a-url').for(:linkedin_url) }
end
