# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Opportunity, type: :model do
  subject(:opportunity) { build(:opportunity) }

  it { is_expected.to belong_to(:scout_run) }
  it { is_expected.to have_many(:evidences).dependent(:nullify) }

  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_presence_of(:problem) }

  it do
    expect(opportunity).to validate_numericality_of(:score)
      .only_integer
      .is_greater_than_or_equal_to(0)
      .is_less_than_or_equal_to(100)
  end

  it do
    expect(opportunity).to validate_numericality_of(:build_fit)
      .only_integer
      .is_greater_than_or_equal_to(0)
      .is_less_than_or_equal_to(100)
      .allow_nil
  end

  it do
    expect(opportunity).to validate_numericality_of(:time_fit)
      .only_integer
      .is_greater_than_or_equal_to(0)
      .is_less_than_or_equal_to(100)
      .allow_nil
  end
end
