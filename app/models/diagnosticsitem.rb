class DiagnosticsItem
  attr_accessor :timestamp, :diagnostic, :value, :timestamp_complete, :diagnostic_complete, :value_complete, :expects_value

  def initialize()
    @timestamp = []
    @diagnostic = []
    @value = []

    @timestamp_complete = false
    @diagnostic_complete = false
    @expects_value = false
  end

  def add_timestamp_byte(byte)
    timestamp.append(byte)
  end

  def add_diagnostic_byte(byte)
    diagnostic.append(byte)

    # todo: set expects value to true or false depending on which diagnostic was written
  end

  def add_value_byte(byte)
    value.append(byte)
  end
end
