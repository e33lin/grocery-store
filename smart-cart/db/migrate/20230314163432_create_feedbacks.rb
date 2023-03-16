class CreateFeedbacks < ActiveRecord::Migration[7.0]
  def change
    create_table :feedbacks do |t|
      t.string :store
      t.string :category
      t.integer :change

      t.timestamps
    end
  end
end
