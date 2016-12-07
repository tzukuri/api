$(function() {
    if (!$('body').hasClass('reserve')) return;

    /**
    the preorderEngine maintains the order state as well as passing order details
    to the API. It also handles updating the DOM where the updates are directly related to the
    state of the engine (updating the nav, showing/hiding glasses, etc.). Other bindings and UI
    updates that are not directly related to the order state should be made outside of this module.

    To add a new step:
    1. create a new .select-step in HTML and populate the markup (e.g. select-size)
    2. add a nav element with the corresponding name (e.g. <a id="size">)
    3. add a handler to _willShow (if any operations should be carried out before showing the step)
    4. add a handler to _didComplete (if any operations should be carried out before hiding the step)
    */
    var preorderEngine = (function() {
      function Step(name, index, element, navElement, willDisplay, didComplete) {
        this.name = name
        this.index = index
        this.element = element
        this.navElement = navElement
        // willDisplay & didComplete are optional, check if they exist before calling them
        this.willDisplay = willDisplay
        this.didComplete = didComplete

        // store a reference to this step on the element
        this.element.data('orderStep', this)

        /**
        when users click on the element for this step, set the selection. Provide a handler in
        _didComplete to override and provide custom functionality
        */
        $('.select-' + name).on('click', function(e) {
          var step = $(this.closest('.step-container')).data('orderStep')

          var selection = $(this).attr('data-' + step.name);
          _order[step.name] = selection;

          if (step.didComplete != undefined) {
            step.didComplete()
          } else {
            _navigateForward()
          }
        })

        this.complete = function(complete) {
          if (complete) {
            this.navElement.addClass('complete').html(_order[this.name])
          } else {
            this.navElement.removeClass('complete').html(this.name)
          }
        }
        this.current = function(current) {
          if (current) {
            this.navElement.addClass('current').html(this.name)
          } else {
            this.navElement.removeClass('current')
          }
        }
      }

      // handlers for step.willDisplay
      var _willShow = {
        frame: function() {
          // show the right frames (depending on utility)
          $('.select-frame img').hide()
          $('.select-frame .' + _order['utility']).show()
        },
        lens: function() {
          var size = _order['frame'] == 'ive' ? tzukuri.models.ive.sizing.small : ''
          _order['size'] = size

          // make sure prescription is always shown first
          $("#lens-type").show()
          $("#lens-size").hide()

          // show the correct size selection images
          $('.select-size img').hide()
          $('.select-size .' + _order['utility']).show()
        },
        checkout: function() {
          $('#checkout-images img').hide()
          $('#checkout-images img.' + _order['frame'] + '.' + _order['utility']).show()

          $('#utility-selection').html(_order['utility'])
          $('#frame-selection').html(_order['frame'])
          $('#lens-selection').html(_order['lens'])
          $('#size-selection').html(_order['size'] + "mm")

          if (_order['lens'] == "prescription") {
              $('#total-selection').html(tzukuri.pricing.total + " AUD")
              $("#contact-prescription").show()
          } else {
              $('#total-selection').html(tzukuri.pricing.total + " AUD")
              $("#contact-prescription").hide()
          }
        }
      }

      // handlers for step.didComplete
      var _didComplete = {
        lens: function() {
          if (_order['frame'] == 'ford') {
            $("#lens-type").fadeOut(function() {$("#lens-size").fadeIn()})
          } else {
            _navigateForward()
          }
        }
      }

      var _steps = (function() {
        var _steps = []
        var _currentStep;

        function _addStep(step) {
          _steps.push(step)
        }

        function _getCurrentStep() {
          return _currentStep
        }

        function _setCurrentStep(step) {
          _currentStep = step
        }

        function _each(callback) {
          _.forEach(_steps, callback)
        }

        function _next() {
          var i = _currentStep == null ? -1 : _currentStep.index
          return _steps[i + 1]
        }

        function _stepWithName(name) {
          return _.find(_steps, function(step) {
            return step.name == name;
          })
        }

        return {
          addStep: _addStep,
          each: _each,
          currentStep: _getCurrentStep,
          setCurrentStep: _setCurrentStep,
          stepWithName: _stepWithName,
          next: _next
        }
      })()

      var _container
      var _nav
      var _order = {}

      function _setOrderValues(values) {
        return _.merge(_order, values)
      }

      function _setCurrentStep(next) {
        if (_steps.currentStep() == null) {
          // if we don't have a current step set this one
          if (next.willDisplay != undefined) next.willDisplay()
          next.element.removeClass('hidden')
        } else {
          // fade between the two steps
          if (next.willDisplay != undefined) next.willDisplay()

          _steps.currentStep().element.addClass('hidden')
          next.element.removeClass('hidden')

          // update the navigation
          _steps.each(function(step, i) {
            if (i == next.index) return;
            step.current(false)
            // step is only complete if index < the index we're about to display
            var complete = i < next.index ? true : false
            step.complete(complete)
          })
        }
        next.current(true)
        next.complete(false)

        // scroll the indicator to the next nav element
        _moveNavIndicator(next.navElement)

        _steps.setCurrentStep(next)
      }

      function _moveNavIndicator(toEl) {
        var width = toEl.width()
        var leftOffset = toEl.offset().left

        _nav.find('#nav-indicator').offset({
          left: leftOffset
        }).css('width', width + 'px')
      }

      function _buildStepForNavEl(navEl, i) {
          var navEl = $(navEl)
          var name = navEl.attr('id')
          var el = _container.find('#step-' + name)

          return new Step(name, i, el, $(navEl), _willShow[name], _didComplete[name])
      }

      function _setPricing() {
        $('.pricing #deposit').html(tzukuri.pricing.deposit)
        $('.pricing #prescription').html(tzukuri.pricing.total)
        $('.pricing #non-prescription').html(tzukuri.pricing.total)
      }

      function _handleApplePayAvailable(available) {
        if (available) {
            $('#apple-pay').show()
            $("#regular-pay").hide()
        } else {
            $('#regular-pay').show()
            $('#apple-pay').hide()
        }
      }

      function _createPayment(token, code) {
        _order['token'] = token.id
        return $.post('/preorders', _order)
      }

      function _navigateBack(stepName) {
        var step = _steps.stepWithName(stepName);
        _setCurrentStep(step)
      }

      function _navigateForward() {
        _setCurrentStep(_steps.next())
      }

      function _init(container, nav){
        // store the container and navigation objects
        _container = container
        _nav = nav

        // check for apple pay available
        // Stripe.applePay.checkAvailability(_handleApplePayAvailable)

        // create steps for each of the elements in the navigation
        _.forEach(_nav.find('a'), function(step, i) {
          var step = _buildStepForNavEl(step, i)
          _steps.addStep(step)
        })

        // set pricing details
        _setPricing()

        _navigateForward()

        $(window).on('resize', function() {
          _moveNavIndicator(_steps.currentStep().navElement)
        })
      }

      // PUBLIC API
      return {
        init: _init,
        setOrderValues: _setOrderValues,
        createPayment: _createPayment,
        navigateBack: _navigateBack,
        navigateForward: _navigateForward
      }
    })();

    $(document).ready(function() {
        preorderEngine.init($('#reserve'), $('#reserve-nav'))

        // polyfill for position:sticky
        $('#glasses').Stickyfill();
    });

    function handlePayment(token) {
        preorderEngine.createPayment(token).done(function(data, status) {
          showFormSpinner(false)
          if (data.success) {
              // show a success screen
               $("html, body").animate({ scrollTop: 0 }, "slow");
              $("#apple-pay, #regular-pay").fadeOut()
              $("#thank-you").fadeIn()
              $("#step-checkout h1").html("thanks for your reservation")
              $("#reserve-nav").fadeOut()

          } else {
              // there was an error creating the preorder/charging the card
              setFormError(data.errors)
          }
        }).fail(function() {
          // there was an error connecting to the server (timeout, etc.)
          setFormError("There was an error submitting your order, please try again. If this continues please contact Tzukuri support.")
          showFormSpinner(false)
        })
    }

    // -------------------
    // bindings
    // -------------------

    // fixme: bit of a hack for the time being, need to be able to support sub-step choices properly
    $('.select-size').on('click', function() {
      var size = $(this).attr('data-size');
      preorderEngine.setOrderValues({
        size: size
      })
      preorderEngine.navigateForward()
    })

    // apple pay submission
    $('.apple-pay-button-with-text').on('click', function(event) {

        // create an apple pay session request and then redirect to a stripe charge
        var paymentRequest = {
            countryCode: 'AU',
            currencyCode: 'USD',
            total: {
                label: 'Tzukuri Pty. Ltd.',
                amount: tzukuri.pricing.nonprescription
            },
            requiredShippingContactFields: ['postalAddress', 'phone', 'email', 'name']
        }

        var applePay = Stripe.applePay.buildSession(paymentRequest, function(result, completion) {
            var shippingContact = result.shippingContact

            // contact details
            preorderEngine.setOrderValues({
              name: shippingContact.givenName + " " + shippingContact.familyName,
              email: shippingContact.emailAddress,
              phone: shippingContact.phoneNumber,

              address_lines: shippingContact.addressLines.push(shippingContact.locality),
              country: shippingContact.country,
              state: shippingContact.administrativeArea,
              postal_code: shippingContact.postal_code,
            })

            // create a payment and inform apple pay session when it is complete
            handlePayment(result.token).done(function(e) {
                if (e.success) {
                    completion(ApplePaySession.STATUS_SUCCESS)
                } else {
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
            if (token.error) {
                setFormError(token.error.message)
                showFormSpinner(false)
            } else {
                handlePayment(token)
            }
        });
    });

    // user clicks on a link in the preorder navigation
    $('#reserve-nav a').on('click', function() {
        if (!$(this).hasClass('complete')) return;
        preorderEngine.navigateBack($(this).attr('id'))
    })

    // simulate a submit click on enter press
    $('#new_preorder').on("keypress", function(e) {
        if (e.keyCode == 13) {
            $("#reserve-submit").click()
        }
    });

    // timer that keeps track of when user is typing
    var coupon_timer;
    var last_amount = tzukuri.pricing.total;

    $("#preorder_coupon").on("input", function() {
      // wait until finished typing and then submit a request to check if the coupon code exists
      clearTimeout(coupon_timer)
      coupon_timer = setTimeout(function() {
        // make a request to the API to check whether or not this coupon is legit
        var coupon = $("#preorder_coupon").val()
        var data = {"coupon": coupon}

        $.post('/coupons', data).done(function(data) {
          // TODO: handle a value that means we don't have to charge the customer's card
          var final_amount = tzukuri.pricing.total

          if (data.exists) {
            final_amount -= (data.coupon.discount / 100)
          } else if (coupon.length > 0) {
            $("#preorder_coupon").tzAnimate('shake')
          }

          if (final_amount == last_amount) return

          // update the values and pulse to bring focus
          $("#total-selection").html(final_amount + " AUD")
          $("#reserve-for").html("reserve for " + final_amount + " AUD")

          $("#reserve-submit").tzAnimate('pulse')
          $("#total-selection").tzAnimate('pulse')

          last_amount = final_amount
        })

      }, 300)
    })

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

    // validate the user's shipping details
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

        var coupon = serialised["preorder[coupon]"]

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
            // store the order details in the navigation object
            preorderEngine.setOrderValues({
              name: name,
              email: email,
              phone: phone,
              address_lines: [address1, address2],
              country: country,
              state: state,
              postal_code: postcode,
              coupon: coupon
            })
        }

        return valid
    }
});
