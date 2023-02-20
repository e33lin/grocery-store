class List < ApplicationRecord

    validates_presence_of :list_id
    validates_presence_of :item
    validates_uniqueness_of :item, case_sensitive: false, message: "item already exists in your list"
    validates_presence_of :quantity

    def self.list_as_array(list)
        a = []
        for x in list
            a.append(x.item)
        end
        return a
    end
end
