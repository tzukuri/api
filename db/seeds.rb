# seed beta questions
BetaQuestion.create(content: "Which phone do you mainly use?",                                                  point_value: 5 )
BetaQuestion.create(content: "Which model of iPhone do you use?",                                               point_value: 5, precondition_id: 1)
BetaQuestion.create(content: "Do you wear prescription glasses?",                                               point_value: 5 )
BetaQuestion.create(content: "What kind of prescription do you have?",                                          point_value: 5, precondition_id: 3)
BetaQuestion.create(content: "How often do you misplace your prescription glasses around the home?",            point_value: 5, precondition_id: 3)
BetaQuestion.create(content: "Have you lost any pair of prescription glasses in the last year?",                point_value: 5, precondition_id: 3)
BetaQuestion.create(content: "How much do you usually spend on your prescription frames (excluding lenses)?",   point_value: 5, precondition_id: 3)
BetaQuestion.create(content: "Do you wear prescription sunglasses?",                                            point_value: 5 )
BetaQuestion.create(content: "How many pairs of sunglasses do you own?",                                        point_value: 5 )
BetaQuestion.create(content: "How many pairs of sunglasses have you lost in the past year?",                    point_value: 5 )
BetaQuestion.create(content: "How often do you misplace your sunglasses around your home?",                     point_value: 5 )
BetaQuestion.create(content: "How much do you usually spend on a pair of sunglasses?",                          point_value: 5 )
BetaQuestion.create(content: "Where do you usually buy your glasses?",                                          point_value: 5 )

# seed first beta user (used to invite everyone else)
BetaUser.create(email: "beta@tzukuri.com", name: "Tzukuri Beta", invite_token:"", birth_date: "26/05/2015", latitude: "0", longitude: "0")

# populate the database with users for testing
# i = 0
# num = 5000

# while i < num do
#   BetaUser.create(email: "beta" + i.to_s + "@tzukuri.com", name: "NAME", invite_token: "", birth_date: "26/05/2015", country: '-', city: '-', score: rand(0..200))
#   i += 1
# end
