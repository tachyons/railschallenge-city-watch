class Responder < ActiveRecord::Base
  validates :capacity, :name, :type, presence: true
  validates :name, uniqueness: true
  validates :capacity, inclusion: 1..5

  def as_json(*_args)
    { emergency_code: code, type: type, name: name, capacity: capacity, on_duty: on_duty }
  end
end
