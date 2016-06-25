class Emergency < ActiveRecord::Base
  validates :fire_severity, :police_severity, :medical_severity, :code, presence: true
  validates :fire_severity, :police_severity, :medical_severity, numericality: { greater_than_or_equal_to: 0 }
  validates :code, uniqueness: true

  def as_json(*args)
    super.merge(responders: responders, full_response: !full_response)
  end

  def full_response
    (fire_severity > Fire.on_duty.to_a.sum(&:capacity)) &&
      (police_severity > Police.on_duty.to_a.sum(&:capacity)) &&
      (medical_severity > Medical.on_duty.to_a.sum(&:capacity))
  end

  def responders
    list = []
    Responder.types.each do |responder|
      klass = responder.constantize
      severity = "#{responder.downcase}_severity"
      if self[severity] > klass.available_capacity
        list += klass.on_duty.collect(&:name)
      elsif self[severity] > 0
        responders_list = []
        klass.on_duty.sort_by(&:capacity).reverse_each do |responder|
          if (responders_list + [responder]).sum(&:capacity) == self[severity]
            responders_list << responder
            list += responders_list.collect(&:name)
          elsif responder.capacity < self[severity]
            responders_list << responder
          end
        end
      end
    end
    list
  end
end
