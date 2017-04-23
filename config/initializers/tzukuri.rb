module Tzukuri
  # points allocated for beta actions
  INVITEE_POINTS  = 10              # points added every time a new user signs up with a user's invite code
  IDENTITY_POINTS = 20              # points added when a social media account is connected to a user
  RESPONSE_POINTS = 5               # points added when a user responds to a new question

  # beta cutoffs
  THRESHOLD_SCORE_DEFAULT = 135     # minimum number of points a user must have to be selected
  NUM_THRESHOLD_USERS     = 100     # number of users that will be selected during the beta program

  # model pricing
  FULL_PRICE = 485 * 100
  PRESCRIPTION_PRICE = 485 * 100
  NONPRESCRIPTION_PRICE = 385 * 100
end
