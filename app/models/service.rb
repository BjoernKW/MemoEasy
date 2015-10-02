class Service < ActiveRecord::Base
  belongs_to :company

  has_many :appointments, :dependent => :destroy

  attr_accessible :name, :duration

  validates :company, :presence => true
  validates :name, :presence => true
  validates :duration, :presence => true, :numericality => { :greater_than_or_equal_to => 0 }

  self.per_page = 10
end
