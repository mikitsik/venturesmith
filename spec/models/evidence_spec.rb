# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Evidence, type: :model do
  subject(:evidence) { build(:evidence) }

  it { is_expected.to belong_to(:scout_run) }
  it { is_expected.to belong_to(:opportunity).optional }

  it { is_expected.to validate_presence_of(:source) }
  it { is_expected.to validate_inclusion_of(:source).in_array(described_class::SOURCES) }
  it { is_expected.to validate_presence_of(:title) }

  it { is_expected.to allow_value('').for(:url) }
  it { is_expected.to allow_value('https://github.com/example/project/issues/1').for(:url) }
  it { is_expected.not_to allow_value('not-a-url').for(:url) }
end
