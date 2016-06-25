class Responder < ActiveRecord::Base
  validates :capacity, :name, :type, presence: true
  validates :name, uniqueness: true
  validates :capacity, inclusion: 1..5

  scope :on_duty, -> { where(on_duty: true) }

  def as_json(*_args)
    { emergency_code: code, type: type, name: name, capacity: capacity, on_duty: on_duty }
  end

  def self.types
    %w(Fire Police Medical)
  end
  def self.available_capacity
    on_duty.to_a.sum(&:capacity)
  end
  def self.severity
    "#{model_name.singular}_severity"
  end
end
