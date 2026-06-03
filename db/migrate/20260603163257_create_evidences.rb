# frozen_string_literal: true

class CreateEvidences < ActiveRecord::Migration[8.1]
  def change
    create_table :evidences do |t|
      t.references :scout_run, null: false, foreign_key: true
      t.references :opportunity, foreign_key: true
      t.string :source, null: false
      t.string :title, null: false
      t.string :url
      t.text :summary
      t.string :signal_type

      t.timestamps
    end

    add_index :evidences, :source
    add_index :evidences, :signal_type
  end
end
