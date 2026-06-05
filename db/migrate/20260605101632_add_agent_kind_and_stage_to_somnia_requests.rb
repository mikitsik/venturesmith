# frozen_string_literal: true

class AddAgentKindAndStageToSomniaRequests < ActiveRecord::Migration[8.1]
  def change
    change_table :somnia_requests, bulk: true do |t|
      t.string :agent_kind, null: false, default: 'llm_inference'
      t.string :stage, null: false, default: 'evaluation'
    end

    add_index :somnia_requests, :agent_kind
    add_index :somnia_requests, :stage
  end
end
