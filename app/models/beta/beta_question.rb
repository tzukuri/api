class BetaQuestion < ActiveRecord::Base
  # a question can have many different responses from different users
  has_many :responses,     :foreign_key => 'beta_question_id', :class_name => 'BetaResponse'
  # a question can have another question as the precondition
  belongs_to :precondition,     :foreign_key => 'precondition_id',  :class_name => 'BetaQuestion'

  def response_options
    case self.id
      # which phone do you mainly use?
      when 1
        return ['iPhone', 'Android Device', 'Windows Phone', 'Other']

      # which model of iPhone do you use?
      when 2
        return ['iPhone 6s', 'iPhone 6', 'iPhone 6s Plus', 'iPhone 6 Plus', 'iPhone 5', 'iPhone 5s', 'iPhone se', 'iPhone 5c', 'Other']

      # do you wear prescription glasses?
      when 3
        return ['Yes', 'No']

      # what kind of prescription do you have?
      when 4
        return ['Short-sighted (Myopia)', 'Farsighted (Hyperopia)', 'Bifocal']

      # how often do you misplace your prescription glasses around the home?
      when 5
        return ['Several times a day', 'Once or twice a week', 'A few times a week', 'Occasionally']

      # have you lost any pair of prescription glasses in the last year?
      when 6
        return ['Yes', 'More than one pair', 'No']

      # how much do you usually spend on your prescription frames (excluding lenses)?
      when 7
        return ['$99 or less', '$100 - $200', '$200 - $350', '$350 - $500', '$500 or more']

      # do you wear prescription sunglasses?
      when 8
        return ['Yes', 'No']

      # how many pairs of sunglasses do you own?
      when 9
        return ['One', 'Two', 'Three', 'Four or more']

      # how many pairs of sunglasses have you lost in the past year?
      when 10
        return ['Zero', 'One', 'Two', 'Three', 'Four or more']

      # how often do you misplace your sunglasses around your home?
      when 11
        return ['Several times a day', 'Once or twice a day', 'A few times a week', 'Rarely']

      # how much do you usually spend on a pair of sunglasses?
      when 12
        return ['$99 or less', '$100 - $200', '$200 - $350', '$350 - $500', '$500 or more']

      when 13
        return ['Sunglass Hut', 'OPSM', 'Specsavers', 'Independent Retailer', 'Online', 'Other']
    end
  end

end
