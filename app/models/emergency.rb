class Emergency < ActiveRecord::Base
  validates_presence_of :fire_severity, :police_severity, :medical_severity, :code
  validates_numericality_of :fire_severity, :police_severity, :medical_severity, greater_than_or_equal_to: 0
  validates_uniqueness_of :code

  def as_json(*args)
    super.merge(emergency: { fire_severity: 1 })
  end
end
