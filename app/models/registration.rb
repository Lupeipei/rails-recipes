class Registration < ApplicationRecord
  belongs_to :ticket, :optional => true
end
