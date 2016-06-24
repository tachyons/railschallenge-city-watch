class Emergency < ActiveRecord::Base
  validates :fire_severity, :police_severity, :medical_severity, :code, presence: true
  validates :fire_severity, :police_severity, :medical_severity, numericality: { greater_than_or_equal_to: 0 }
  validates :code, uniqueness: true

  def as_json(*args)
    super.merge(emergency: { fire_severity: 1 }, responders: [], full_response: [])
  end
end
