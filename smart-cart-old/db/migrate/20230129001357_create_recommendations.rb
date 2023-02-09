class CreateRecommendations < ActiveRecord::Migration[7.0]
  def change
    create_table :recommendations do |t|
      t.integer :list_id
      t.integer :rec_num
      t.string :store
      t.decimal :subtotal
      t.json :rec

      t.timestamps
    end
  end
end
