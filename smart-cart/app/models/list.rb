class List < ApplicationRecord

    validates_presence_of :list_id
    validates_presence_of :item
    validates_presence_of :quantity

    def self.list_as_array(list)
        a = []
        for x in list
            a.append(x.item)
        end
        return a
    end
end
