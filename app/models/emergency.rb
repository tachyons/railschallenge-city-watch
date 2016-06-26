class Emergency < ActiveRecord::Base
  validates :fire_severity, :police_severity, :medical_severity, :code, presence: true
  validates :fire_severity, :police_severity, :medical_severity, numericality: { greater_than_or_equal_to: 0 }
  validates :code, uniqueness: true
  has_many :responders
  after_create :setup_responders
  before_save :resolve, if: :resolved_at_changed?

  scope :resolved, -> { where('resolved_at NOT NULL') }

  def as_json(*args)
    super.merge(responders: responders_name, full_response: !full_response)
  end

  def full_response
    (fire_severity > Fire.on_duty.to_a.sum(&:capacity)) &&
      (police_severity > Police.on_duty.to_a.sum(&:capacity)) &&
      (medical_severity > Medical.on_duty.to_a.sum(&:capacity))
  end

  def responders_name
    responders.to_a.collect(&:name)
  end

  def resolve
    responders.each do |responder|
      responder.update_attributes(emergency: nil)
    end
  end

  def setup_responders
    Responder.types.each do |responder|
      klass = responder.constantize
      severity = "#{responder.downcase}_severity"
      responders_array = []
      responders_list = []
      if self[severity] > klass.available_capacity
        responders_array += klass.on_duty.to_a
      elsif self[severity] > 0
        klass.on_duty.sort_by(&:capacity).reverse_each do |responder|
          if (responders_list + [responder]).sum(&:capacity) == self[severity]
            responders_list << responder
            responders_array += responders_list
          elsif responder.capacity < self[severity]
            responders_list << responder
          end
        end
      end
      responders_array.each do |responder|
        responder.update_attributes(emergency: self)
      end
    end
  end
end
