class Recommendation < ApplicationRecord
    validates_presence_of :list_id
    validates_presence_of :rec_num
    validates_presence_of :store
    validates_presence_of :subtotal
    validates_presence_of :rec
end
