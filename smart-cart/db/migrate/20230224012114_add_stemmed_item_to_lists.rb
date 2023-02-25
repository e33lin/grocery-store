class AddStemmedItemToLists < ActiveRecord::Migration[7.0]
  def change
    add_column :lists, :stemmed_item, :string
  end
end
