class CreatePromoCodes < ActiveRecord::Migration[8.0]
  def change
    create_table :promo_codes do |t|
      t.timestamps
      t.string :name, null: false, index: {unique: true}
      t.jsonb :advantage, null: false, default: {}
    end
  end
end
