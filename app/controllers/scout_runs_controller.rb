# frozen_string_literal: true

class ScoutRunsController < ApplicationController
  def show
    @scout_run = ScoutRun
                 .includes(:user_profile, :somnia_requests, :opportunities, :evidences)
                 .find(params.expect(:id))
  end

  def create
    user_profile = UserProfile.find(params.expect(:user_profile_id))

    scout_run = user_profile.scout_runs.create!(
      scout_run_params.merge(status: 'draft')
    )

    Scout::SomniaPipeline.new.call(scout_run:)

    redirect_to scout_run
  end

  private

  def scout_run_params
    params.expect(scout_run: %i[goal wallet_address])
  end
end
