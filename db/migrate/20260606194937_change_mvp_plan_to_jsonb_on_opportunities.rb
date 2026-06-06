# frozen_string_literal: true

class ChangeMvpPlanToJsonbOnOpportunities < ActiveRecord::Migration[8.1]
  def up
    add_column :opportunities, :mvp_plan_jsonb, :jsonb, null: false, default: []

    execute <<~SQL.squish
      UPDATE opportunities
      SET mvp_plan_jsonb =
        CASE
          WHEN mvp_plan IS NULL OR btrim(mvp_plan) = '' THEN '[]'::jsonb
          ELSE mvp_plan::jsonb
        END
    SQL

    remove_column :opportunities, :mvp_plan
    rename_column :opportunities, :mvp_plan_jsonb, :mvp_plan
  end

  def down
    add_column :opportunities, :mvp_plan_text, :text

    execute <<~SQL.squish
      UPDATE opportunities
      SET mvp_plan_text = mvp_plan::text
    SQL

    remove_column :opportunities, :mvp_plan
    rename_column :opportunities, :mvp_plan_text, :mvp_plan
  end
end
