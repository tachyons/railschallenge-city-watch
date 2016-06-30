class Emergency < ActiveRecord::Base
  validates :fire_severity, :police_severity, :medical_severity, :code, presence: true
  validates :fire_severity, :police_severity, :medical_severity, numericality: { greater_than_or_equal_to: 0 }
  validates :code, uniqueness: true
  has_many :responders, dependent: :nullify
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
      # When capacity is not enough
      if self[severity] >= klass.available_capacity
        responders_array += klass.on_duty.to_a
      # Single responder is enough
      elsif klass.on_duty.where(capacity: self[severity]).present?
        responders_array = [klass.on_duty.find_by(capacity: self[severity])]
      elsif self[severity] > 0
        list = klass.on_duty.sort_by(&:capacity).reverse
        1.upto(list.length) do |num|
          list.each_slice(num) do |slice|
            responders_array += slice if slice.sum(&:capacity) == self[severity]
          end
        end
        if responders_array.empty?
          1.upto(list.length) do |num|
            list.each_slice(num) do |slice|
              responders_array += slice if slice.sum(&:capacity) >= self[severity]
            end
          end
        end
      end
      responders_array.each do |responder|
        responder.update_attributes(emergency: self)
      end
    end
  end
end
