class CustomerSet < ActiveRecord::Base
	belongs_to :company

  has_many :customers, :dependent => :destroy

  attr_accessible :customers

  self.per_page = 10
end
