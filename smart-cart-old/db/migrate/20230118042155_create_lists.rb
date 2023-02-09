class CreateLists < ActiveRecord::Migration[7.0]
  def change
    create_table :lists do |t|
      t.integer :list_id
      t.integer :quantity
      t.string :item

      t.timestamps
    end
  end
end
