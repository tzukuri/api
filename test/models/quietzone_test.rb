require 'test_helper'

class QuietzoneTest < ActiveSupport::TestCase

  def setup
    @quietzone = Quietzone.new(name: "TEST ZONE", latitude: -33.758876, longitude: 151.103704, radius: 25, starttime: Time.now, endtime: Time.now, user_id:1)
  end

  test "should be valid" do
    assert @quietzone.valid?
  end

  # =====================
  # PRESENCE TESTS
  # =====================
  test "name should be present" do
    # whitespace name
    @quietzone.name = "     "
    assert_not @quietzone.valid?

    # blank name
    @quietzone.name = ""
    assert_not @quietzone.valid?
  end

  test "latitude should be present" do
    @quietzone.latitude = nil
    assert_not @quietzone.valid?
  end

  test "longitude should be present" do
    @quietzone.longitude = nil
    assert_not @quietzone.valid?
  end

  test "radius should be present" do
    @quietzone.radius = nil
    assert_not @quietzone.valid?
  end

  test "user id should be present" do
    @quietzone.user_id = nil
    assert_not @quietzone.valid?
  end

  # =====================
  # VALIDITIY TESTS
  # =====================
  test "latitude should be valid" do
    @quietzone.latitude = 150
    assert_not @quietzone.valid?
  end

  test "longitude should be valid" do
    @quietzone.longitude = 199
    assert_not @quietzone.valid?
  end

end
