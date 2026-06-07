# frozen_string_literal: true

class RemoveFounderProfileRunsAndAttachSomniaRequestsToUserProfiles < ActiveRecord::Migration[8.1]
  def change
    add_reference :somnia_requests, :user_profile, foreign_key: true, index: true

    change_column_null :somnia_requests, :scout_run_id, true

    # rubocop:disable Rails/ReversibleMigration
    drop_table :founder_profile_runs, if_exists: true
    # rubocop:enable Rails/ReversibleMigration
  end
end
