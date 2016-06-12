class Responder < ActiveRecord::Base
  validates_presence_of :capacity, :name, :type
  validates_uniqueness_of :name
  validates :capacity, inclusion: 1..5

  def as_json(*_args)
    { responder: { emergency_code: code, type: type, name: name, capacity: capacity, on_duty: on_duty } }
  end
end
