class CheckRegistrationJob < ApplicationJob
  queue_as :default

  def perform(registration_id)
    registration = Regisration.find(registration_id)

    unless registration.status == "confirmed"
      registration.status = "cancelled"
      registration.save!
    end
  end
  
end
