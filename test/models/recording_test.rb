require 'test_helper'

class RecordingTest < ActiveSupport::TestCase

  def setup
    @recording = Recording.new(device_id: 0, room_id:0, recording_date: 1457054992, data: File.open("#{Rails.root}/test/models/testdata.txt"))
  end

  test "should be valid" do
    puts @recording.inspect
    assert @recording.valid?
  end

  test "device id should be present" do
    @recording.device_id = nil;
    assert_not @recording.valid?
  end

  test "room id should be present" do
    @recording.room_id = nil;
    assert_not @recording.valid?
  end

  test "recording date should be present" do
    @recording.recording_date = nil
    assert_not @recording.valid?
  end

  test "data file should be present" do
    @recording.data = nil
    assert_not @recording.valid?
  end

end
