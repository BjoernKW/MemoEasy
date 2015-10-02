class Assignment < ActiveRecord::Base
  belongs_to :slot
  belongs_to :staff_member

  attr_accessible :slot, :staff_member, :slot_id, :staff_member_id

  accepts_nested_attributes_for :slot
  accepts_nested_attributes_for :staff_member

  validates :slot, :presence => true
  validates :staff_member, :presence => true

  self.per_page = 10
end
