class Recommendation < ApplicationRecord
    validates_presence_of :list_id
    validates_presence_of :rec_num
    validates_presence_of :store
    validates_presence_of :subtotal
    validates_presence_of :rec
    serialize :store

    def self.find_name(store)
        store_name = ""
        if (store == "no_frills")
            store_name = "No Frills"
        elsif (store == "food_basics")
            store_name = "Food Basics"
        elsif (store == "freshco")
            store_name = "FreshCo"
        elsif (store == "sobeys")
            store_name = "Sobeys"
        elsif (store == "valu_mart")
            store_name = "Valu-mart"
        elsif (store == "walmart")
            store_name = "Walmart"
        elsif (store == "zehrs")
            store_name = "Zehrs"
        end
        return store_name
    end
end
