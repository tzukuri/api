$(function() {
    if (!$('body').hasClass('reserve')) return;

    var navigation = {
        // step.callback is called just before that step is shown (use to setup the view correctly)
        steps: {
            utility: {
                name: 'utility',
                index: 0,
                element: $('#step-utility'),
                navElement: $('#reserve-nav #utility'),
                callback: function() {}
            },
            frame: {
                name: 'frame',
                index: 1,
                element: $('#step-frame'),
                navElement: $('#reserve-nav #frame'),
                callback: function() {
                    // show the right frames (depending on utility)
                    $('.select-frame img').hide()
                    $('.select-frame .' + navigation.order.utility).show()
                }
            },
            lens: {
                name: 'lens',
                index: 2,
                element: $('#step-lenses'),
                navElement: $('#reserve-nav #lens'),
                callback: function() {
                  // if we've selected ive, there is only one size
                  if (navigation.order.frame == "ive") {
                    navigation.order.size = tzukuri.models.ive.sizing.small;
                  } else {
                    navigation.order.size = ""
                  }

                  // make sure prescription is always shown first
                  $("#lens-type").show()
                  $("#lens-size").hide()

                  // show the correct size selection images
                  $('.select-size img').hide()
                  $('.select-size .' + navigation.order.utility).show()
                }
            },
            checkout: {
                name: 'checkout',
                index: 3,
                element: $('#step-checkout'),
                navElement: $('#reserve-nav #checkout'),
                callback: function() {
                    $('#checkout-images img').hide()
                    $('#checkout-images img.' + navigation.order.frame + '.' + navigation.order.utility).show()

                    $('#utility-selection').html(navigation.order.utility)
                    $('#frame-selection').html(navigation.order.frame)
                    $('#lens-selection').html(navigation.order.lens)
                    $('#size-selection').html(navigation.order.size + "mm")

                    if (navigation.order.lens == "prescription") {
                        $('#total-selection').html(tzukuri.pricing.totals.prescription - navigation.discount + " AUD")
                        $('.remainder').html(tzukuri.pricing.totals.prescription - tzukuri.pricing.deposit - navigation.discount)
                        $("#contact-prescription").show()
                    } else {
                        $('#total-selection').html(tzukuri.pricing.totals.nonprescription - navigation.discount + " AUD")
                        $('.remainder').html(tzukuri.pricing.totals.nonprescription - tzukuri.pricing.deposit - navigation.discount)
                        $("#contact-prescription").hide()
                    }


                }
            }
        },

        stack: [],
        discount: 0,

        // the (main) container with all the step divs
        stepContainer: $('.step-container'),

        // object that keeps track of the order
        order: {
            utility: '',
            frame: '',
            size: '',
            lens: ''
        },

        currentStep: function() {
            return this.stack[this.stack.length - 1]
        },

        setCurrentStep: function(nextStep) {
            // todo: refactor this method (too long)
            var currentStep = this.currentStep()

            // if we don't have a current step just fade this one in and push on the stack (probably the first time running)
            if (currentStep == null) {
                nextStep.element.fadeIn()
                nextStep.navElement.addClass('current')

                this.stack.push(nextStep)
            } else {
                // fade out the current step and fade in the next step
                currentStep.element.fadeOut(function() {
                    nextStep.element.fadeIn()
                })

                // if we moving forward, add to the stack
                if (nextStep.index > currentStep.index) {
                    this.stack.push(nextStep)

                    currentStep.navElement.addClass('complete').removeClass('current')
                    nextStep.navElement.addClass('current')
                } else {
                    // 1. find the index of the step in the stack
                    var i = _.findIndex(this.stack, function(s) {
                        return s == nextStep
                    })

                    // 2. get the removed steps
                    var removed = this.stack.splice(i + 1, this.stack.length)

                    // 3. update the navigation bar
                    _.forEach(removed, function(removedStep) {
                        removedStep.navElement.removeClass('complete current').html(removedStep.name)
                    });

                    // 4. set the navigation bar current state
                    nextStep.navElement.removeClass('complete').addClass('current')
                }
            }

            nextStep.callback()
        },

        setSelectionForStep: function(selection, step) {
            // store the selection in the order object and update the nav element
            this.order[step.name] = selection
            step.navElement.html(selection)

            // progress to the next step
            var newStep = this.steps[Object.keys(this.steps)[step.index + 1]]
            this.setCurrentStep(newStep)
        },

        init: function() {
            // hide all the containers
            this.stepContainer.hide()

            // set utility as the first step
            this.setCurrentStep(this.steps.utility)

            // set the pricing details
            $('.pricing #deposit').html(tzukuri.pricing.deposit)
            $('.pricing #prescription').html(tzukuri.pricing.totals.prescription - tzukuri.pricing.deposit - navigation.discount)
            $('.pricing #non-prescription').html(tzukuri.pricing.totals.nonprescription - tzukuri.pricing.deposit - navigation.discount)
        }
    }

    $(document).ready(function() {
        // set a discount (if the server accepted a code)
        navigation.discount = parseInt($("#reserve").attr('data-discount'))

        navigation.init()
        Stripe.applePay.checkAvailability(handleApplePayAvailable)

        //  polyfill for position:sticky
        $('#glasses').Stickyfill();
    });

    // given a token and a preorder, create a preorder and a charge on the API
    function createPayment(token, preorder) {
        preorder.token = token.id
        preorder.code = $('#reserve').attr('data-code')

        // create a preorder
        return $.post('/preorders', preorder, function(data, status) {
            showFormSpinner(false)
            if (data.success) {
                // show a success screen
                $("#apple-pay, #regular-pay").fadeOut()
                $("#thank-you").fadeIn()
                $("#step-checkout h1").html("thanks for your reservation")
                $("#reserve-nav").fadeOut()
            } else {
                // there was an error creating the preorder/charging the card
                setFormError(data.reason)
            }
        }).fail(function() {
            // there was an error connecting to the server (timeout, etc.)
            setFormError("There was an error submitting your order, please try again. If this continues please contact Tzukuri support.")
            showFormSpinner(false)
        })
    }

    // -------------------
    // step bindings
    // -------------------

    // user selects a utility (optical vs. sun)
    $('.select-utility').on('click', function() {
        var utility = $(this).attr('data-utility');
        navigation.setSelectionForStep(utility, navigation.steps.utility);
    })

    // user selects a frame (ive vs. ford)
    $('.select-frame').on('click', function() {
        var frame = $(this).attr('data-frame');
        navigation.setSelectionForStep(frame, navigation.steps.frame);
    })

    // user selects a lens (prescription vs. non-prescription)
    $('.select-lens').on('click', function() {
        var lens = $(this).attr('data-lens');

        if (navigation.order.frame == "ford") {
          // store the lens on the order but don't navigate
          navigation.order.lens = lens;

          // fade in the size selection
          $("#lens-type").fadeOut(function() {
            $("#lens-size").fadeIn()
          })
        } else {
          navigation.setSelectionForStep(lens, navigation.steps.lens);
        }
    })

    $('.select-size').on('click', function() {
      var size = $(this).attr('data-size');
      navigation.order.size = size;

      // proceed to checkout by setting the lens data on the nav
      navigation.setSelectionForStep(navigation.order.lens, navigation.steps.lens)
    })


    // apple pay submission
    $('.apple-pay-button-with-text').on('click', function(event) {

        // create an apple pay session request and then redirect to a stripe charge
        var paymentRequest = {
            countryCode: 'AU',
            currencyCode: 'AUD',
            total: {
                label: 'Tzukuri Pty. Ltd.',
                amount: tzukuri.pricing.deposit
            },
            requiredShippingContactFields: ['postalAddress', 'phone', 'email', 'name']
        }

        var applePay = Stripe.applePay.buildSession(paymentRequest, function(result, completion) {
            console.log(result, completion)

            var shippingContact = result.shippingContact

            // contact details
            navigation.order.name = shippingContact.givenName + " " + shippingContact.familyName
            navigation.order.email = shippingContact.emailAddress
            navigation.order.phone = shippingContact.phoneNumber

            // shipping details
            navigation.order.address_lines = shippingContact.addressLines
            navigation.order.address_lines.push(shippingContact.locality)
            navigation.order.country = shippingContact.country
            navigation.order.state = shippingContact.administrativeArea
            navigation.order.postal_code = shippingContact.postalCode

            // create a payment and inform apple pay session when it is complete
            createPayment(result.token, navigation.order).done(function(e) {
                if (e.success) {
                    completion(ApplePaySession.STATUS_SUCCESS)
                } else {
                    // todo: show an error message
                    completion(ApplePaySession.STATUS_FAILURE)
                }
            }).fail(function() {
                completion(ApplePaySession.STATUS_FAILURE)
            })
        })

        applePay.begin()
    })

    // regular pay submission
    $('#payment-form').submit(function(event) {
        event.preventDefault()

        var shippingValid = validateShipping($('#new_preorder'))
        var paymentValid = validatePayment($('#payment-form'))

        if (!shippingValid || !paymentValid) {
            // one or more form fields are invalid
            setFormError("Some fields are missing or invalid.")
            return
        };

        // show the spinner to indicate network activity
        showFormSpinner(true)

        Stripe.card.createToken($(this), function(status, token) {
            console.log(status)
            if (token.error) {
                // todo: display an error (there was an error processing the card)
                setFormError(token.error.message)
                showFormSpinner(false)
            } else {
                createPayment(token, navigation.order)
            }
        });
    });


    // user clicks on a link in the preorder navigation
    $('#reserve-nav a').on('click', function() {
        if (!$(this).hasClass('complete')) return;

        var nextStep = navigation.steps[$(this).attr('id')]
        navigation.setCurrentStep(nextStep);
    })

    // -------------------
    // helper bindings
    // -------------------

    // simulate a submit click on enter press
    $('#new_preorder').on("keypress", function(e) {
        if (e.keyCode == 13) {
            $("#reserve-submit").click()
        }
    });

    // prevent multiple clicks from firing events more than once while step-container is animating
    $('.select-utility, .select-frame, .select-lens, .select-size').on('click', function(event) {
        if ($(this).closest(".step-container").is(":animated")) {
            event.stopImmediatePropagation()
        };
    })

    // pulse the images on mouse over
    $('.select-utility img, .select-frame img, .select-lens img, .select-size img').on('mouseenter', function() {
        $(this).tzAnimate('pulse')
    })

    // user is shown apple pay but wants to use the normal form
    $('#ignore-apple-pay').on('click', function(event) {
        event.preventDefault()

        $('#apple-pay').fadeOut(function() {
            $('#regular-pay').fadeIn()
        })
    })

    // -------------------
    // helper methods
    // -------------------

    // show a spinner in the submit button to indicate network activity
    var showFormSpinner = function(showFormSpinner) {
      var hideEl = showFormSpinner ? "#reserve-submit" : "#submit-spinner"
      var showEl = showFormSpinner ? "#submit-spinner" : "#reserve-submit"

      // clear the form error field if showing the spinner
      if (showFormSpinner) setFormError()

      $(hideEl).hide()
      $(showEl).show()

      $('#reserve-submit').prop('disabled', showFormSpinner)
    }

    // display apple pay as default if it is available
    var handleApplePayAvailable = function(available) {
        if (available) {
            $('#apple-pay').show()
            $("#regular-pay").hide()
        } else {
            $('#regular-pay').show()
            $('#apple-pay').hide()
        }
    }

    // add the error state to a form input
    var addError = function(element) {
        $(element).addClass('error')
        return false
    }

    // set an error message for the form, if message is not passed it will clear the error field
    var setFormError = function(message) {
        if (message == null) {
          $("#error-messages").html("").hide()
          return;
        }

        $('#error-messages').html(message).show()
        $('#reserve-submit').tzAnimate('shake')
    }

    // validate the user's payment details
    var validatePayment = function(form) {
        var valid = true
        var serialised = form.serializeObject()

        form.find('input').removeClass('error')

        var ccNumber = serialised["number"]
        var CVV = serialised["CVV"]

        // if cc not valid
        if (ccNumber.length == 0) {
            // just checking it is not empty - letting stripe handle the actual validation
            valid = addError("#payment_ccNumber");
        }

        // if cvv not valid?
        if (CVV == "") {
            valid = addError("#payment_cvv")
        }

        return valid;
    }

    // validat ethe user's shipping details
    var validateShipping = function(form) {
        var valid = true
        var serialised = form.serializeObject()

        form.find('input').removeClass('error')

        // contact details
        var name = serialised["preorder[name]"]
        var phone = serialised["preorder[phone]"].replace(" ", "")
        var email = serialised["preorder[email]"]

        // address details
        var address1 = serialised["preorder[address1]"]
        var address2 = serialised["preorder[address2]"]
        var postcode = serialised["preorder[postal_code]"]
        var state = serialised["preorder[state]"]
        var country = $('#preorder_country').val()

        var ausPhoneNumbers = /^\({0,1}((0|\+61)(2|4|3|7|8)){0,1}\){0,1}(\ |-){0,1}[0-9]{2}(\ |-){0,1}[0-9]{2}(\ |-){0,1}[0-9]{1}(\ |-){0,1}[0-9]{3}$/;

        if (name.length == 0) {
            valid = addError("#preorder_name")
        }

        // check address 1 exists
        if (address1.length == 0) {
            valid = addError("#preorder_address1")
        }

        // check postcode exists and is a number
        if (postcode.length != 4 || !/^\d+$/.test(postcode)) {
            valid = addError("#preorder_postal_code")
        }

        if (state.length == 0) {
            valid = addError("#preorder_state")
        }

        // check phone exists and is a valid australian phone number
        if (phone.length == 0 || !ausPhoneNumbers.test(phone)) {
            valid = addError("#preorder_phone")
        }

        if (email.length == 0) {
            valid = addError("#preorder_email")
        }

        if (valid) {
            // todo: store the order details in the navigation object
            navigation.order.name = name
            navigation.order.email = email
            navigation.order.phone = phone

            // shipping details
            navigation.order.address_lines = [address1, address2]
            navigation.order.country = country
            navigation.order.state = state
            navigation.order.postal_code = postcode
        }

        return valid
    }
});
