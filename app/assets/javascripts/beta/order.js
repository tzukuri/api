$(function() {
    if (!$('body').hasClass('beta')) return;


    // -----------------------------
    // beta orders functionality
    // -----------------------------

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

    // callbacks for when a view is shown
    var didShowStep = {
        getStarted: function() {},
        acceptAndContinue: function() {},
        selectFrame: function() {},
        selectSize: function() {
            var lg = tzukuri.models[orderDetails.frame].sizing.large
            var sm = tzukuri.models[orderDetails.frame].sizing.small

            // update the sizing for the selected frame
            $('.select-size #small').html(sm + "mm").attr('data-size', sm)
            $('.select-size #large').html(lg + "mm").attr('data-size', lg)
        },
        shippingDetails: function() {
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
        deliveryMethod: function() {
            // make sure the timeslot details have been reset
            orderDetails.timeslot = {}
        },
        timeslotSelect: function() {
            // reset the selection details
            $("#timeslot-continue").hide()
            $("#booking-time #date").html("")
            $("#booking-time #time").html("Choose an available time from the list below")

            // reinitialise the timekit UI
            var timekit = new TimekitBooking()

            var config = {
              email:    'beta@tzukuri.com',
              apiToken: 'XAuyu7wMLLjSlF6pltBJR4x8d4W3tN7W',
              calendar: '348c52b6-ae68-40d3-9781-2ea308505f04',

              //optional
              targetEl: '#bookingjs',
              name: 'Tzukuri',
              showCredits: false,

              fullCalendar: {
                defaultView: 'basicWeek',
                eventClick: function(event) {
                    orderDetails.timeslot.start = event.start
                    orderDetails.timeslot.end = event.end

                    // update the view
                    $("#booking-time #date").html(orderDetails.timeslot.start.format("dddd, MMMM D"))
                    $("#booking-time #time").html(orderDetails.timeslot.start.format(" [at] h:mm a"))
                    $("#timeslot-continue").fadeIn()
                }
              },

              timekitFindTime: {
                future: '4 weeks',
                length: '1 hour',
                start: 'tomorrow',
                emails: ['beta@tzukuri.com', 'd@tzukuri.com', 'a@tzukuri.com'],
                filters: {
                    and: [
                        { "exclude_weekend": {}},
                        { "specific_time": {"start": 10, "end": 16}}
                    ],
                    or: [
                        { "specific_day": {"day": "Thursday"}},
                        { "specific_day": {"day": "Friday"}}
                    ]
                }
              },

              localization: {
                  timeDateFormat: '24h-dmy-mon',
              }
            };

            timekit.init(config);
        },
        orderReview: function() {
            // make sure the order details are up to date
            $("#conf-frame").html(orderDetails.frame)
            $("#conf-size").html(orderDetails.size + "mm")
            $("#conf-address").html(formattedAddress());

            var shipping = orderDetails.delivery_method === "ship" ? "Standard Shipping" : "Personal Fitting"
            $("#conf-shipping").html(shipping)

            if (typeof orderDetails.timeslot.start !== 'undefined') {
                var formattedTime = moment(orderDetails.timeslot.start).format("dddd MMM D [@] h:mm A")
                $("#conf-timeslot").html(formattedTime)
                $("#conf-timeslot-header, #conf-timeslot").show()
            } else {
                $("#conf-timeslot-header, #conf-timeslot").hide()
            }
        }
    }

    // prevent multiple clicks from firing events more than once while
    // the parent .step-container is animating
    $('.next, .prev').on('click', function(event) {
        if ($(this).closest(".step-container").is(":animated")) {
            event.stopImmediatePropagation()
        };
    })

    // 0 - get started
    $("#step-intro #get-started").on('click', function() {
        navigate('forward')
    })

    // 1 - accept and continue
    $('#step-accept .next').on('click', function() {
        navigate('forward')
    })

    // 2 - user selects a frame
    $('.select-frame button').on('click', function() {
        orderDetails.frame = $(this).attr('data-frame')
        navigate('forward')
    })

    // 3 - user selects a size
    $('.select-size button').on('click', function() {
        orderDetails.size = $(this).attr('data-size')
        navigate('forward')
    })

    // 4 - user enters shipping information
    $('#shipping-continue').on('click', function() {
        var form = $("#new_beta_order")

        // validate the form and save the data, stop if the form is invalid
        if (!validatesShippingDetails($("#new_beta_order").serializeObject())) {
            $("#shipping-continue").tzAnimate('shake')
            return
        };

        // replace button with searching icon
        $("#shipping-continue").hide()
        $(".loading-spinner").show();
        $("#error-messages").html("")

        geocodeAddress(formattedAddress()).done(function(data) {
            if (data.results.length == 0) {
                // could not find location
                $("#error-messages").html("Could not validate this address, check your details are correct and try again.")

                $(".loading-spinner").hide()
                $("#shipping-continue").show()

                return;
            }

            var addr_coords = data.results[0].geometry
            var syd_coords = {'lat': -33.865, 'lng': 151.209444}

            var distance = distanceBetweenCoords(addr_coords, syd_coords)

            // if there are no timeslots remaining or they are too far away
            // immediately navigate to the review page
            // if (distance > 15) {
            //     navigateToIndex(7)
            // } else {
            //     navigate('forward')
            // }

            if (distance < 15) {
                navigateToIndex(6)
            } else {
                $("#error-messages").html("Please enter an address within 15km of the Sydney CBD.")
            }


            $(".loading-spinner").hide()
            $("#shipping-continue").show()

        }).fail(function() {
            $("#error-messages").html("An error occurred validating this address. Please try again.")
            $(".loading-spinner").hide()
            $("#shipping-continue").show()
        })

        return
    })

    // 5 - user selects their shipping method (optional)
    $('.select-shipping button').on('click', function() {
        var type = parseInt($(this).attr('data-delivery'))
        orderDetails.delivery_method = type == 0 ? "ship" : "deliver"

        if ($(this).attr('data-delivery') == "0") {
            navigateToIndex(7)
        } else if ($(this).attr('data-delivery') == "1") {
            navigate('forward')
        }
    })

    // 6 - user selects their timeslot (optional)
    $('#timeslot-continue').on('click', function() {
        navigate('forward')
    })

    // 7 - review and place order
    $("#place-order").on('click', function() {
        var data = submitOrderDetails()

        $('#payment-message').text("Submitting your order...");
        $("#place-order").hide();

        $.post('/beta_orders', data).done(function(data) {
            if (data.success) {
                location.reload()
                $('#payment-message').text("");
            } else {
                $('#payment-message').text("Sorry, an unknown error occurred.");
                    $('#submit button').prop('disabled', false);
                    $("#place-order").show()
                    $('#place-order').tzAnimate('shake')
            }

        }).fail(function() {
            $('#payment-message').text("Sorry, an unknown error occurred.");
            $('#submit button').prop('disabled', false);
            $("#place-order").show()
            $('#place-order').tzAnimate('shake')
        })
    })

    $('.prev').on('click', function() {
        navigate('back')
    })

    // enable enter key to submit the form
    $('#new_beta_order').on("keypress", function(e) {
        if (e.keyCode == 13) {
            $("#shipping-continue").click()
        }
    });

    // --------------------
    // helper functions
    // --------------------
    var navigateToIndex = function(index) {
        var steps = $('.step-container')
        var currentStep = navigationStack[navigationStack.length-1]

        if (index > currentStep) {
            // moving forward so push the new index on the stack
            navigationStack.push(index)
        } else {
            // moving backward so pop the last index off the stack
            currentStep = navigationStack.pop()
        }

        $(steps[currentStep]).fadeOut(function() {
            $(steps[index]).fadeIn()
        });

        // call one of the step callbacks
        switch(index) {
            case 0:
                didShowStep.getStarted()
                break;
            case 1:
                didShowStep.acceptAndContinue()
                break;
            case 2:
                didShowStep.selectFrame()
                break;
            case 3:
                didShowStep.selectSize()
                break;
            case 4:
                didShowStep.shippingDetails()
                break;
            case 5:
                didShowStep.deliveryMethod()
                break;
            case 6:
                didShowStep.timeslotSelect()
                break;
            case 7:
                didShowStep.orderReview()
                break;
        }
    }

    // navigate back or forward through the order steps
    var navigate = function(direction) {
        if (direction == "forward") {
            navigateToIndex(navigationStack[navigationStack.length-1] + 1)
        } else if (direction == "back") {
            navigateToIndex(navigationStack[navigationStack.length-2])
        }
    }

    var submitOrderDetails = function() {
        var details = {
            frame: orderDetails.frame,
            size: orderDetails.size,
            delivery_method: orderDetails.delivery_method,
            shipping_name: orderDetails.address["beta_order[shipping_name]"],
            address1: orderDetails.address["beta_order[address1]"],
            address2: orderDetails.address["beta_order[address2]"],
            state: orderDetails.address["state"],
            postcode: orderDetails.address["beta_order[postcode]"],
            country: 'australia',
            phone: orderDetails.address["beta_order[phone]"]
        }

        // only return the timeslot details if they're set
        if (typeof orderDetails.timeslot.start !== 'undefined') {
            details.timeslot_start = orderDetails.timeslot.start.toISOString()
        }

        if (typeof orderDetails.timeslot.end !== 'undefined') {
            details.timeslot_end = orderDetails.timeslot.end.toISOString()
        }

        return details
    }

    var formattedAddress = function() {
        return orderDetails.address["beta_order[address1]"] + ", " + orderDetails.address["beta_order[address2]"] + ", " + orderDetails.address["state"] + ", Australia" + ", " + orderDetails.address["beta_order[postcode]"]
    }

    var addError = function(element) {
        $(element).addClass('error')
        return false
    }

    var validatesShippingDetails = function(serialisedForm) {
        var valid = true

        var name = serialisedForm["beta_order[shipping_name]"]
        var address1 = serialisedForm["beta_order[address1]"]
        var address2 = serialisedForm["beta_order[address2]"]
        var postcode = serialisedForm["beta_order[postcode]"]
        var state = serialisedForm["beta_order[state]"]
        var phone = serialisedForm["beta_order[phone]"].replace(" ", "")

        var ausPhoneNumbers = /^\({0,1}((0|\+61)(2|4|3|7|8)){0,1}\){0,1}(\ |-){0,1}[0-9]{2}(\ |-){0,1}[0-9]{2}(\ |-){0,1}[0-9]{1}(\ |-){0,1}[0-9]{3}$/;

        // remove all error classes
        $("#new_beta_order input").removeClass('error')

        if (name.length == 0) {
            valid = addError("#beta_order_shipping_name")
        }

        // check address 1 exists
        if (address1.length == 0) {
            valid = addError("#beta_order_address1")
        }

        // check postcode exists and is a number
        if (postcode.length != 4 || !/^\d+$/.test(postcode)) {
            valid = addError("#beta_order_postcode")
        }

        // check phone exists and is a valid australian phone number
        if (phone.length == 0 || !ausPhoneNumbers.test(phone)) {
            valid = addError("#beta_order_phone")
        }

        if (valid) {
            orderDetails.address = serialisedForm;
        }

        return valid
    }

    var geocodeAddress = function(address) {
        var API_KEY = '0828d5780c7f32be6e3882357f8a2038'
        var url = "https://api.opencagedata.com/geocode/v1/json?q=" + address + "&key=" + API_KEY
        return $.get(url)
    }

    var distanceBetweenCoords = function(coords1, coords2) {
        // using the haversine formula to calculate great-circle distance
        var p = 0.017453292519943295;    // Math.PI / 180
        var c = Math.cos;
        var a = 0.5 - c((coords2.lat - coords1.lat) * p)/2 + c(coords1.lat * p) * c(coords2.lat * p) * (1 - c((coords2.lng - coords1.lng) * p))/2;
        return 12742 * Math.asin(Math.sqrt(a)); // 2 * R; R = 6371 km
    }
});
