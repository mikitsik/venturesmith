# frozen_string_literal: true

class CreateOpportunities < ActiveRecord::Migration[8.1]
  def change
    create_table :opportunities do |t|
      t.references :scout_run, null: false, foreign_key: true
      t.string :title, null: false
      t.text :problem, null: false
      t.string :audience
      t.integer :score, null: false
      t.integer :build_fit
      t.integer :time_fit
      t.text :evidence_summary
      t.text :mvp_plan

      t.timestamps
    end

    add_index :opportunities, :score
  end
end
