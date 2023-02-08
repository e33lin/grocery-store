class List < ApplicationRecord
    def self.list_as_array(list)
        a = []
        for x in list
            a.append(x.item)
        end
        return a
    end
end
