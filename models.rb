class Card < ActiveRecord::Base
	belongs_to :user
end

class User < ActiveRecord::Base
	has_many :cards
end