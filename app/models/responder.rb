class Responder < ActiveRecord::Base
  validates :capacity, :name, :type, presence: true
  validates :name, uniqueness: true
  validates :capacity, inclusion: 1..5
  belongs_to :emergency

  scope :on_duty, -> { where(on_duty: true) }
  scope :not_in_duty, -> { where(on_duty: false) }
  scope :allocated, -> { where('emeregency_id IS NOT NULL') }
  scope :available, -> { where(emergency: nil) }

  def as_json(*_args)
    { emergency_code: code, type: type, name: name, capacity: capacity, on_duty: on_duty }
  end

  def self.types
    %w(Fire Police Medical)
  end

  def self.available_capacity
    available.to_a.sum(&:capacity)
  end

  def self.severity
    "#{model_name.singular}_severity"
  end

  def self.status
    [all.to_a.sum(&:capacity), available.to_a.sum(&:capacity), on_duty.to_a.sum(&:capacity), available.on_duty.to_a.sum(&:capacity)]
  end

  def self.available_responders
    { capacity: {
      Fire: Fire.status,
      Police: Police.status,
      Medical: Medical.status
    } }
  end
end
