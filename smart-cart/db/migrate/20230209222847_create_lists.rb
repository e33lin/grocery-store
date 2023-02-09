class CreateLists < ActiveRecord::Migration[7.0]
  def change
    create_table :lists do |t|
      t.integer :list_id
      t.string :item
      t.integer :quantity

      t.timestamps
    end
  end
end
