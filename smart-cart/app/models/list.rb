class List < ApplicationRecord

    validates_presence_of :list_id
    validates_presence_of :item
    validates_presence_of :quantity

    # generates an array of the items the current user has added to their list
    def self.list_as_array(list)
        a = []
        for x in list
            a.append(x.item)
        end
        return a
    end

    # generates an array of the quantities of each item
    def self.item_quantities_as_array(list)
        a = []
        for x in list
            a.append(x.quantity)
        end
        return a
    end
end
