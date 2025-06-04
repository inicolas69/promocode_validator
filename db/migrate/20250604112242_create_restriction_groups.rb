class CreateRestrictionGroups < ActiveRecord::Migration[8.0]
  def change
    create_table :restriction_groups do |t|
      t.timestamps
      t.string :operator, null: false, default: "and"
      t.references :restrictable, polymorphic: true, null: false
    end
  end
end
