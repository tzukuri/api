require 'test_helper'

class BetaSignupTest < ActiveSupport::TestCase

  def setup
    @signup1 = BetaSignup.create(email: "test1@tzukuri.com", country: "Australia")
    @signup2 = BetaSignup.create(email: "test2@tzukuri.com", country: "Australia")
    @signup3 = BetaSignup.create(email: "test3@tzukuri.com", country: "Australia")
  end

  test "does create signup" do
    assert_not_nil @signup1
    assert_not_nil @signup2
  end

  # validation tests
  # ---------------------
  test "does generate invite code" do
    assert_not_nil @signup1.invite_code
  end

  test "does validate email presence" do
    # setup
    @signup1.email = ""
    # exercise
    @signup1.save
    # verify
    assert !@signup1.valid?
    assert @signup2.valid?
  end

  test "does validate email format" do
    @signup1.email = "invalid@email"
    @signup1.save

    assert @signup1.invalid?
    assert @signup2.valid?
  end

  test "does validate unique email" do
    dup_email_signup = BetaSignup.create(email: "test1@tzukuri.com", country: "Australia")
    assert dup_email_signup.invalid?
  end

  test "does validate country presence" do
    @signup1.country = ""
    @signup1.save

    assert @signup1.invalid?
    assert @signup2.valid?
  end

  test "does set invite code" do
    assert_not_nil @signup1.invite_code
    assert_not_nil @signup2.invite_code
  end

  test "has invite code of length 6" do
    assert @signup1.invite_code.length == 6, "invite code should have length 6"
  end

  # relationship tests
  # ----------------------
  test "does set invited_by" do
    @signup1.invite(@signup2)
    assert @signup2.invited_by == @signup1
  end

  test "does set invitees" do
    @signup1.invite(@signup2)
    @signup1.invite(@signup3)
    assert @signup1.invitees.count == 2
  end

  test "does set score" do
    @signup1.invite(@signup2)
    @signup1.invite(@signup3)

    assert @signup1.score == 2
    assert @signup2.score == 1
    assert @signup3.score == 1
  end


end
