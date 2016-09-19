$(function() {
    if (!$('body').hasClass('preorder')) return;

    $('.select-type, .select-frame, .select-size').on('mouseover', function() {
        $(this).tzAnimate('pulse')
    })

    // keep track of information user has entered throughout the process
    var orderDetails = {
        frame: '',
        size: '',
        address: {},
        delivery_method: 'ship',
        timeslot: {}
    }

    // keep track of the progress to through each of the steps. navigating forward pushes onto the stack and navigating back
    // pops off the stack. Always starting at the 0th element
    var navigationStack = [0]

    var navigation = {
        steps: {
            type: 0,
            frame: 1,
            size: 2,
            delivery: 3,
            peyment: 4
        },
        stepCallbacks: {
            // callbacks for each step
            type: function() {},
            frame: function() {
                if (orderDetails.type == 'sun') {
                    $('#step-frames img.sun').show()
                    $('#step-frames img.optical').hide()
                } else {
                    $('#step-frames img.optical').show()
                    $('#step-frames img.sun').hide()
                }
            },
            size: function() {
                var lg = tzukuri.models[orderDetails.frame].sizing.large
                var sm = tzukuri.models[orderDetails.frame].sizing.small

                // update the sizing for the selected frame
                $('.select-size#small').html(sm + "mm").attr('data-size', sm)
                $('.select-size#large').html(lg + "mm").attr('data-size', lg)
            },
            delivery: function() {
                if (orderDetails.frame == "ive") {
                    $("#ive-black, #conf-ive-black").show()
                    $("#ford-black, #conf-ford-black").hide()
                } else {
                    $("#ive-black, #conf-ive-black").hide()
                    $("#ford-black, #conf-ford-black").show()
                }

                $("#size-selection").html(orderDetails.size + "mm")
                $("#frame-selection").html(orderDetails.frame)
            },
            payment: function() {}
        },
        stack: [0],
        navElement: $('#preorder-nav'),
        stepContainer: $('.step-container'),

        currentStep: function() {
            return this.stack[this.stack.length - 1]
        },

        setCurrentStep: function(step) {
            var step = Object.keys(this.steps)[step]

            this.navElement.find('.current').removeClass('current')
            this.navElement.find('#' + step).addClass('current')

            $(this.stepContainer[this.currentStep()]).fadeOut(function(step) {
                $(this.stepContainer[step]).fadeIn()
            })

            if (step > this.currentStep()) {
                this.stack.push(step)
            } else {
                this.stack.pop()
            }

            // todo: update the order details in the navigation bar

            // call the callback for this step
            this.stepCallbacks[step]()
        }
    }

    // callbacks for when a view is shown
    // var didShowStep = {
    //     deliveryMethod: function() {
    //         // make sure the timeslot details have been reset
    //         orderDetails.timeslot = {}
    //     },
    //     timeslotSelect: function() {
    //         // reset the selection details
    //         $("#timeslot-continue").hide()
    //         $("#booking-time #date").html("")
    //         $("#booking-time #time").html("Choose an available time from the list below")

    //         // reinitialise the timekit UI
    //         var timekit = new TimekitBooking()

    //         var config = {
    //           email:    'beta@tzukuri.com',
    //           apiToken: 'XAuyu7wMLLjSlF6pltBJR4x8d4W3tN7W',
    //           calendar: '348c52b6-ae68-40d3-9781-2ea308505f04',

    //           //optional
    //           targetEl: '#bookingjs',
    //           name: 'Tzukuri',
    //           showCredits: false,

    //           fullCalendar: {
    //             defaultView: 'basicWeek',
    //             eventClick: function(event) {
    //                 orderDetails.timeslot.start = event.start
    //                 orderDetails.timeslot.end = event.end

    //                 // update the view
    //                 $("#booking-time #date").html(orderDetails.timeslot.start.format("dddd, MMMM D"))
    //                 $("#booking-time #time").html(orderDetails.timeslot.start.format(" [at] h:mm a"))
    //                 $("#timeslot-continue").fadeIn()
    //             }
    //           },

    //           timekitFindTime: {
    //             future: '2 weeks',
    //             length: '1 hour',
    //             start: 'tomorrow',
    //             emails: ['beta@tzukuri.com', 'd@tzukuri.com', 'a@tzukuri.com'],
    //             filters: {
    //                 and: [
    //                     { "exclude_weekend": {}},
    //                     { "specific_time": {"start": 10, "end": 16}}
    //                 ],
    //                 or: [
    //                     { "specific_day": {"day": "Thursday"}},
    //                     { "specific_day": {"day": "Friday"}}
    //                 ]
    //             }
    //           },

    //           localization: {
    //               timeDateFormat: '24h-dmy-mon',
    //           }
    //         };

    //         timekit.init(config);
    //     },
    //     orderReview: function() {
    //         // make sure the order details are up to date
    //         $("#conf-frame").html(orderDetails.frame)
    //         $("#conf-size").html(orderDetails.size + "mm")
    //         $("#conf-address").html(formattedAddress());

    //         var shipping = orderDetails.delivery_method === "ship" ? "Standard Shipping" : "Personal Fitting"
    //         $("#conf-shipping").html(shipping)

    //         if (typeof orderDetails.timeslot.start !== 'undefined') {
    //             var formattedTime = moment(orderDetails.timeslot.start).format("dddd MMM D [@] h:mm A")
    //             $("#conf-timeslot").html(formattedTime)
    //             $("#conf-timeslot-header, #conf-timeslot").show()
    //         } else {
    //             $("#conf-timeslot-header, #conf-timeslot").hide()
    //         }
    //     }
    // }

    // prevent multiple clicks from firing events more than once while
    // the parent .step-container is animating
    $('.next, .prev').on('click', function(event) {
        if ($(this).closest(".step-container").is(":animated")) {
            event.stopImmediatePropagation()
        };
    })

    // 1 - user selects a frame type
    $('.select-type').on('click', function() {
        orderDetails.type = $(this).attr('data-type')
        navigate('forward')
    })

    // 2 - user selects a frame
    $('.select-frame').on('click', function() {
        orderDetails.frame = $(this).attr('data-frame')
        navigate('forward')
    })

    // 3 - user selects a size
    $('.select-size').on('click', function() {
        orderDetails.size = $(this).attr('data-size')
        navigate('forward')
    })

    // 4 - user enters shipping information
    $('#shipping-continue').on('click', function() {
        var form = $("#new_purchase")

        // validate the form and save the data, stop if the form is invalid
        if (!validatesShippingDetails($("#new_purchase").serializeObject())) {
            $("#shipping-continue").tzAnimate('shake')
            return
        };

        navigate('forward')

        return
    })

    $('.prev').on('click', function() {
        navigate('back')
    })

    // enable enter key to submit the form
    $('#new_purchase').on("keypress", function(e) {
        if (e.keyCode == 13) {
            $("#shipping-continue").click()
        }
    });

    // --------------------
    // helper functions
    // --------------------
    // navigate back or forward through the order steps
    var navigate = function(direction) {
        if (direction == "forward") {
            navigation.setCurrentStep(navigation.currentStep() + 1)
        } else if (direction == "back") {
            navigation.setCurrentStep(navigation.currentStep() - 1)
        }
    }

    var formattedAddress = function() {
        return orderDetails.address["purchase[address1]"] + ", " + orderDetails.address["purchase[address2]"] + ", " + orderDetails.address["state"] + ", Australia" + ", " + orderDetails.address["purchase[postcode]"]
    }

    var addError = function(element) {
        $(element).addClass('error')
        return false
    }

    var validatesShippingDetails = function(serialisedForm) {
        var valid = true

        var name = serialisedForm["purchase[name]"]
        var address1 = serialisedForm["purchase[address1]"]
        var address2 = serialisedForm["purchase[address2]"]
        var postcode = serialisedForm["purchase[postcode]"]
        var state = serialisedForm["purchase[state]"]
        var phone = serialisedForm["purchase[phone]"].replace(" ", "")
        var email = serialisedForm["purchase[email]"]

        var ausPhoneNumbers = /^\({0,1}((0|\+61)(2|4|3|7|8)){0,1}\){0,1}(\ |-){0,1}[0-9]{2}(\ |-){0,1}[0-9]{2}(\ |-){0,1}[0-9]{1}(\ |-){0,1}[0-9]{3}$/;

        // remove all error classes
        $("#new_purchase input").removeClass('error')

        if (name.length == 0) {
            valid = addError("#purchase_name")
        }

        // check address 1 exists
        if (address1.length == 0) {
            valid = addError("#purchase_address1")
        }

        // check postcode exists and is a number
        if (postcode.length != 4 || !/^\d+$/.test(postcode)) {
            valid = addError("#purchase_postcode")
        }

        // check phone exists and is a valid australian phone number
        if (phone.length == 0 || !ausPhoneNumbers.test(phone)) {
            valid = addError("#purchase_phone")
        }

        if (email.length == 0) {
            valid = addError("#purchase_email")
        }

        if (valid) {
            orderDetails.address = serialisedForm;
        }

        return valid
    }

    function stripeResponseHandler(status, response) {
        if (response.error) {
            $('#payment-message').text(response.error.message);
            $('#submit button').prop('disabled', false);
        } else {
            $('#payment-message').text("Charging your card...");

            $.post('/purchases', {
                email: orderDetails.address["purchase[email]"],
                name: orderDetails.address["purchase[name]"],
                phone: orderDetails.address["purchase[phone]"],
                address1: orderDetails.address["purchase[address1]"],
                address2: orderDetails.address["purchase[address2]"],
                state: orderDetails.address["state"],
                postcode: orderDetails.address["purchase[postcode]"],
                country: 'Australia',
                token: response.id,
                frame: orderDetails.frame,
                colour: 'Black',
                size: orderDetails.size
            }, function(data, status) {
                if (data.success) {
                    console.log('success')
                    location.reload()
                } else {
                    if (data.reason)
                        $('#payment-message').text(data.reason);
                    else
                        $('#payment-message').text('Sorry, an unknown error occurred.');
                        $('#submit button').prop('disabled', false);
                }
            }, 'json').fail(function() {
                $('#payment-message').text('Sorry, an unknown error occurred. Please try again later.');
            });
        }
    }

    $('#payment-form').submit(function(event) {
        $("#submit button").prop('disabled', true);
        $('#payment-message').text("Checking your card details...");
        Stripe.card.createToken($(this), stripeResponseHandler);
        event.preventDefault()
    });

});
