class Registration < ApplicationRecord

  STATUS = ["pending", "confirmed"]
  validates_inclusion_of :status, :in => STATUS
  validates_presence_of :status, :ticket_id

  belongs_to :ticket
  belongs_to :user, :optional => true
  belongs_to :event

  before_validation :generate_uuid, :on => :create

  attr_accessor :current_step
  validates_presence_of :name, :email, :cellphone, :if => :should_validate_basic_data?
  validates_presence_of :name, :email, :cellphone, :bio, :if => :should_validate_all_data?

  def to_param
    self.uuid
  end

  validate :check_event_status, :on => :create

  protected

  def generate_uuid
    self.uuid = SecureRandom.uuid
  end

  def should_validate_basic_data?
    current_step == 2
  end

  def should_validate_all_data?
    current_step == 3 || status == "confirmed"
  end

  def check_event_status
    if self.event.status == "draft"
      errors.add(:base, "活动尚未开放报名")
    end
  end
end
