class BetaUser < ActiveRecord::Base

  devise :omniauthable, :my_authentication

  has_many :identities

  # todo: implement twitter/facebook/instagram strategies here

end
