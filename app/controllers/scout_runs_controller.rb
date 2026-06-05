# frozen_string_literal: true

class ScoutRunsController < ApplicationController
  def show
    @scout_run = ScoutRun.includes(:user_profile, :somnia_request).find(params.expect(:id))
  end

  def create
    user_profile = UserProfile.find(params.expect(:user_profile_id))
    scout_run = user_profile.scout_runs.create!(scout_run_params)

    scout_run.create_somnia_request!(
      agent_id: 'scout-agent-v1',
      status: 'draft',
      payload: {
        goal: scout_run.goal,
        user_profile_id: user_profile.id
      }
    )

    redirect_to scout_run
  end

  private

  def scout_run_params
    params.expect(scout_run: %i[goal wallet_address])
  end
end
