class CreateRestrictions < ActiveRecord::Migration[8.0]
  def change
    create_table :restrictions do |t|
      t.timestamps
      t.string :type, null: false, index: true

      t.references :restriction_group, null: false
      t.jsonb :conditions, null: false, default: {}
    end
  end
end
