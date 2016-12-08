$(function() {
    if (!$('body').hasClass('gift')) return;

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
        checkout: function() {
          $('#total-selection').html(tzukuri.pricing.total + " AUD")
        }
      }

      // handlers for step.didComplete
      var _didComplete = {}

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
        return $.post('/gifts', _order)
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
        navigateForward: _navigateForward,
        order: _order
      }
    })();

    $(document).ready(function() {
        preorderEngine.init($('#gift'), $('#gift-nav'))

        // polyfill for position:sticky
        $('#glasses').Stickyfill();
    });

    function handlePayment(token) {
        preorderEngine.createPayment(token).done(function(data, status) {
          showFormSpinner(false)
          console.log(data)
          if (data.success) {
              // show a success screen
              $("html, body").animate({ scrollTop: 0 }, "slow");
              $("#apple-pay, #regular-pay").fadeOut()
              $("#thank-you").fadeIn()
              $("#step-checkout h1").html("thanks for your purchase")
              $("#gift-nav").fadeOut()
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

    // regular pay submission
    $('#payment-form').submit(function(event) {
        event.preventDefault()

        var shippingValid = validateShipping($('#new_gift'))
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
    $('#gift-nav a').on('click', function() {
        if (!$(this).hasClass('complete')) return;
        preorderEngine.navigateBack($(this).attr('id'))
    })

    // simulate a submit click on enter press
    $('#new_gift').on("keypress", function(e) {
        if (e.keyCode == 13) {
            $("#reserve-submit").click()
        }
    });

    // timer that keeps track of when user is typing
    var coupon_timer;
    var last_amount = tzukuri.pricing.total;

    $("#gift_coupon").on("input", function() {
      // wait until finished typing and then submit a request to check if the coupon code exists
      clearTimeout(coupon_timer)
      coupon_timer = setTimeout(function() {
        // make a request to the API to check whether or not this coupon is legit
        var coupon = $("#gift_coupon").val()
        var data = {"coupon": coupon}

        $.post('/coupons', data).done(function(data) {
          // handle a value that means we don't have to charge the customer's card

           if (data.type == "COUPON") {
            handleCoupon(data.token)
          } else {
            $("#gift_coupon").tzAnimate('shake')
            updatePrice(tzukuri.pricing.total)
          }
        })
      }, 300)
    })

    // user is shown apple pay but wants to use the normal form
    $('#ignore-apple-pay').on('click', function(event) {
        event.preventDefault()

        $('#apple-pay').fadeOut(function() {
            $('#regular-pay').fadeIn()
        })
    })

    $("#welcome-continue").on('click', function(event) {
      preorderEngine.navigateForward()
    })

    // -------------------
    // helper methods
    // -------------------

    var handleGift = function(gift) {
      // replace payment information form with just a submit button
      $("#payment-form, #total-price").fadeOut(function() {
        $("#gift-redeem").fadeIn()
      })
    }

    var handleCoupon = function(coupon) {
      var final_amount = tzukuri.pricing.total
      final_amount -= (coupon.discount / 100)

      if (final_amount == last_amount) return

      updatePrice(final_amount)
    }

    // update the amount we say we are going to charge on the final view
    var updatePrice = function(amount) {
      // update the values and pulse to bring focus
      $("#total-selection").html(amount + " AUD")
      $("#reserve-for").html("reserve for " + amount + " AUD")

      $("#reserve-submit").tzAnimate('pulse')
      $("#total-selection").tzAnimate('pulse')

      last_amount = amount
    }

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
        $('#reserve-submit, #gift-redeem').tzAnimate('shake')
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

        console.log(serialised)

        form.find('input').removeClass('error')

        // contact details
        var email = serialised["gift[purchased_by]"]
        var coupon = serialised["gift[coupon]"]

        if (email.length == 0) {
            valid = addError("#gift_purchased_by")
        }

        if (valid) {
            // store the order details in the navigation object
            preorderEngine.setOrderValues({
              purchased_by: email,
              coupon: coupon
            })
        }

        return valid
    }
});
