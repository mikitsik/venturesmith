# frozen_string_literal: true

class CreateFounderProfileRuns < ActiveRecord::Migration[8.1]
  def change
    create_table :founder_profile_runs do |t|
      t.references :user_profile, null: false, foreign_key: true
      t.string :status, null: false, default: 'draft'
      t.string :source, null: false, default: 'github'
      t.jsonb :profile_data, null: false, default: {}
      t.text :error_message

      t.timestamps
    end

    add_index :founder_profile_runs, :status
    add_index :founder_profile_runs, :source
  end
end
