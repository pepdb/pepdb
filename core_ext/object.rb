class Object
  # extending object class with mehtod burrowed from RoR
  # abbreviates obj.nil? || obj.empty? test
  def blank?
    respond_to?(:empty?) ? !!empty? : !self
  end
end
