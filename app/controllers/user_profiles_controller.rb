# frozen_string_literal: true

class UserProfilesController < ApplicationController
  def show
    @user_profile = UserProfile.find(params.expect(:id))
    @scout_run = @user_profile.scout_runs.build
  end

  def new
    @user_profile = UserProfile.new
  end

  def create
    @user_profile = UserProfile.new(user_profile_params)

    if @user_profile.save
      redirect_to @user_profile
    else
      render :new, status: :unprocessable_content
    end
  end

  private

  def user_profile_params
    params.expect(user_profile: %i[name background available_days github_url linkedin_url])
  end
end
