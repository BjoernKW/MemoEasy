class Slot < ActiveRecord::Base
  belongs_to :company

  has_many :assignments, :dependent => :destroy
  has_many :staff_members, :through => :assignments

  default_scope { order('weekday ASC') }
  scope :opening_hours, -> { where(blocker: false).order('weekday ASC') }
  scope :blockers, -> { where(blocker: true).order('weekday ASC') }

  attr_accessible :starts_at_picker, :ends_at_picker,
                  :starts_at_hour, :starts_at_minute,
  				        :ends_at_hour, :ends_at_minute, :weekday, :blocker

  validates :company, :presence => true
  validates :starts_at_hour, :presence => true, :numericality => { :greater_than_or_equal_to => 0 }
  validates :starts_at_minute, :presence => true, :numericality => { :greater_than_or_equal_to => 0 }
  validates :ends_at_hour, :presence => true, :numericality => { :greater_than_or_equal_to => 0 }
  validates :ends_at_minute, :presence => true, :numericality => { :greater_than_or_equal_to => 0 }
  validates :weekday, :presence => true, :numericality => { :greater_than_or_equal_to => 1 }, :numericality => { :less_than_or_equal_to => 7 }

  validate :validate_end_date_before_start_date

  self.per_page = 10

  attr_accessor :starts_at_picker
  attr_accessor :ends_at_picker

  def display_time_component(component)
    "%02d" % component
  end

  def duration
    self.ends_at_hour - self.starts_at_hour - self.starts_at_minute + self.ends_at_minute
  end

  def duration_in_minutes
    self.duration * 60
  end

  def duration_in_seconds
    self.duration_in_minutes * 60
  end

  def cwday
    self.weekday > 0 ? self.weekday : 7
  end

  private
    def end_time_is_before_start_time
      if ends_at_hour && ends_at_minute && starts_at_hour && starts_at_minute
        return (ends_at_hour < starts_at_hour) || (ends_at_hour == starts_at_hour && ends_at_minute < starts_at_minute)
      end
      return false
    end

    def validate_end_date_before_start_date
      errors.add(:end_date, I18n.t('end_time_is_before_start_time')) if end_time_is_before_start_time
    end
end
