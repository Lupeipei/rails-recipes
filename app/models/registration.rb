class Registration < ApplicationRecord

  STATUS = ["pending", "confirmed"]
  validates_inclusion_of :status, :in => STATUS
  validates_presence_of :status, :ticket_id

  belongs_to :ticket
  belongs_to :user, :optional => true
  belongs_to :event

  before_validation :generate_uuid, :on => :create

  def to_param
    self.uuid
  end

  protected

  def generate_uuid
    self.uuid = SecureRandom.uuid
  end
end
