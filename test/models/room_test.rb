require 'test_helper'

class RoomTest < ActiveSupport::TestCase

  def setup
    @room = Room.new(name: "TEST ROOM", quietzone_id: 1);
  end

  test "should be valid" do
    assert @room.valid?
  end

  test "name should be present" do
    # whitespace name
    @room.name = "     "
    assert_not @room.valid?

    # blank name
    @room.name = ""
    assert_not @room.valid?
  end

  test "quietzone_id should be present" do
    @room.quietzone_id = nil

    assert_not @room.valid?
  end

end
