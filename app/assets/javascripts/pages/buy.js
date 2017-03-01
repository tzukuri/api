var el, order, CheckoutWidget = {

  elements: {
    utilitySelect: $("#utility-select"),
    lensSelectOptical: $("#lens-select-optical"),
    lensSelectSun: $('#lens-select-sun'),
    prescriptionSelect: $('#prescription-select'),
    sizeSelect: $('#size-select'),

    buyFordButton: $("#buy-ford"),
    buyIveButton: $("#buy-ive"),

    backButton: $("#checkout-back"),

    checkoutFrame: $('#checkout'),
    purchaseFrame: $('#purchase'),

    utilityFormGroup: $("#utility-group"),
    lensSunFormGroup: $("#lens-group-sun"),
    lensOpticalFormGroup: $('#lens-group-optical'),
    prescriptionFormGroup: $("#prescription-group"),
    sizeFormGroup: $('#size-group'),
    orderForm: $("#new_preorder"),
    paymentForm: $("#payment-form"),
    glassesForm: $("#glasses-form"),

    orderDescription: $("#order-desc"),

    fordOptical: $("#Ford-Optical"),
    fordSun: $("#Ford-Sun"),
    iveOptical: $("#Ive-Optical"),
    iveSun: $("#Ive-Sun"),
    allGlasses: $(".glasses"),

    orderDiv: $("#order-form"),
    orderCompleteDiv: $("#order-complete")
  },

  order: {
    frame: undefined,
    utility: undefined,
    lens: undefined,
    prescription: undefined,

    name: undefined,
    email: undefined,
    phone: undefined,

    address_lines: undefined,
    state: undefined,
    postalCode: undefined,
    country: undefined,

    token: undefined
  },

  init: function() {
    el = this.elements
    order = _.clone(this.order)
    console.log(order)

    this.bindUIActions()
  },

  bindUIActions: function() {
    // bind to checkout selects
    el.utilitySelect.on('change', function() {
      CheckoutWidget.utilityChange(this.value)
    })

    el.sizeSelect.on('change', function() {
      CheckoutWidget.sizeChange(this.value)
    })

    el.lensSelectOptical.on('change', function() {
      CheckoutWidget.lensChange(this.value)
    })

    el.lensSelectSun.on('change', function() {
      CheckoutWidget.lensChange(this.value)
    })

    el.prescriptionSelect.on('change', function() {
      CheckoutWidget.prescriptionChange(this.value)
    })

    // bind actions to buy clicks
    el.buyFordButton.on('click', function() {
      CheckoutWidget.selectFrame('Ford')
    })
    el.buyIveButton.on('click', function() {
      CheckoutWidget.selectFrame('Ive')
    })

    // checkout back
    el.backButton.on('click', function() {
      CheckoutWidget.goBack()
    })

    el.paymentForm.submit(function(ev) {
      ev.preventDefault()
      CheckoutWidget.submit()
    })
  },

  // validation and error handling
  addError: function(el) {
    $(el).addClass('error')
    return false
  },

  validateOrder: function() {
    var valid = true
    var serialised = el.orderForm.serializeObject()

    el.orderForm.find('input').removeClass('error')

    // contact details
    var name = serialised["preorder[name]"]
    var phone = serialised["preorder[phone]"].replace(" ", "")
    var email = serialised["preorder[email]"]

    // address details
    var address = serialised["preorder[address1]"]
    var postcode = serialised["preorder[postal_code]"]
    var state = serialised["preorder[state]"]
    var country = $('#preorder_country').val()

    var coupon = serialised["preorder[coupon]"]

    var ausPhoneNumbers = /^\({0,1}((0|\+61)(2|4|3|7|8)){0,1}\){0,1}(\ |-){0,1}[0-9]{2}(\ |-){0,1}[0-9]{2}(\ |-){0,1}[0-9]{1}(\ |-){0,1}[0-9]{3}$/;

    if (name.length == 0) {
        valid = CheckoutWidget.addError("#preorder_name")
    }

    // check address 1 exists
    if (address.length == 0) {
        valid = CheckoutWidget.addError("#preorder_address1")
    }

    // check postcode exists and is a number
    if (postcode.length != 4 || !/^\d+$/.test(postcode)) {
        valid = CheckoutWidget.addError("#preorder_postal_code")
    }

    if (state.length == 0) {
        valid = CheckoutWidget.addError("#preorder_state")
    }

    // check phone exists and is a valid australian phone number
    if (phone.length == 0 || !ausPhoneNumbers.test(phone)) {
        valid = CheckoutWidget.addError("#preorder_phone")
    }

    if (email.length == 0) {
        valid = CheckoutWidget.addError("#preorder_email")
    }

    if (valid) {
      order.name = name
      order.email = email
      order.phone = phone

      order.address_lines = [address]
      order.postal_code = postcode
      order.state = state
      order.country = country
    }

    return valid
  },

  validatePayment: function() {
    var valid = true
    var serialised = el.paymentForm.serializeObject()

    el.paymentForm.find('input').removeClass('error')

    var ccNumber = serialised["number"]
    var CVV = serialised["CVV"]

    // if cc not valid
    if (ccNumber.length == 0) {
        // just checking it is not empty - letting stripe handle the actual validation
        valid = CheckoutWidget.addError("#payment_ccNumber");
    }

    // if cvv not valid?
    if (CVV == "") {
        valid = CheckoutWidget.addError("#payment_cvv")
    }

    return valid;
  },

  setFormError: function(message) {
    if (message == null) {
      $("#error-messages").html("").hide()
      return;
    }

    $('#error-messages').html(message).show()
    // $('#reserve-submit, #gift-redeem').tzAnimate('shake')
  },

  showFormSpinner: function(show) {
    var hideEl = show ? '#reserve-submit' : '#submit-spinner'
    var showEl = show ? '#submit-spinner' : '#reserve-submit'

    if (show) CheckoutWidget.setFormError()

    $(hideEl).hide()
    $(showEl).show()

    $('#reserve-submit').prop('disabled', show)
  },

  // update the order description with the latest order details
  updateOrderDesc: function() {
      el.orderDescription.find('#frame').html(order.frame)
      el.orderDescription.find('#utility').html(order.utility)
      el.orderDescription.find('#lens').html(order.lens)
  },

  submit: function() {
    // validate shipping and payment forms
    var shippingValid = CheckoutWidget.validateOrder()
    var paymentValid = CheckoutWidget.validatePayment()

    if (!shippingValid || !paymentValid) {
        // one or more form fields are invalid
        CheckoutWidget.setFormError("Some fields are missing or invalid.")
        return
    };

    CheckoutWidget.showFormSpinner(true)

    // show the spinner inidicating network activity
    Stripe.card.createToken(el.paymentForm, function(status, token) {
      if (token.error) {
        // display the error on the form
        CheckoutWidget.setFormError(token.error.message)
        CheckoutWidget.showFormSpinner(false)
      } else {
        order.token = token.id

        $.post('/preorders', order).done(function(data) {
          CheckoutWidget.showFormSpinner(false)

          if (data.success) {
            el.orderDiv.fadeOut(function() {
              el.orderCompleteDiv.fadeIn()
            })
          }
        }).fail(function(error) {
          CheckoutWidget.setFormError("An error occured while submitting your order.")
          CheckoutWidget.showFormSpinner(false)
        })
      }
    })
  },

  // returns the element that contains the glasses image
  getGlassesEl: function(frame, utility = "Optical") {
    if (utility == "Optical") {
      return frame == "Ive" ? el.iveOptical : el.fordOptical
    } else if (utility == "Sun") {
      return frame == "Ive" ? el.iveSun : el.fordSun
    }
  },

  // called when the utility changes
  utilityChange: function(utility) {
    if (utility == "Sun") {
      el.lensOpticalFormGroup.fadeOut(function() {
        el.lensSelectOptical.prop('selectedIndex', 0);
        el.lensSunFormGroup.fadeIn()
      })
    } else {
      el.lensSunFormGroup.fadeOut(function() {
        el.lensSelectSun.prop('selectedIndex', 0);
        el.lensOpticalFormGroup.fadeIn()
      })
    }

    order.prescription = null
    order.lens = null
    el.prescriptionSelect.prop('selectedIndex', 0)
    el.prescriptionFormGroup.fadeOut()

    CheckoutWidget.getGlassesEl(order.frame, order.utility).fadeOut(function() {
      CheckoutWidget.getGlassesEl(order.frame, utility).fadeIn()
    })

    order.utility = utility

    CheckoutWidget.updateOrderDesc()

    console.log(order)
  },

  sizeChange: function(size) {
    order.size = size
  },

  // called when the lens type is changed
  lensChange: function(lens) {
    order.lens = lens

    CheckoutWidget.updateOrderDesc()

    // if they have select non-prescription, we don't need to ask for their prescription
    if (lens == "Non-Prescription") {
      order.prescription = null
      el.prescriptionFormGroup.fadeOut()
      el.orderForm.fadeIn()
      el.paymentForm.fadeIn()
      el.prescriptionSelect.prop('selectedIndex', 0);
    } else {
      el.prescriptionFormGroup.fadeIn()
    }

    console.log(order)
  },

  // called when the prescription delivery select is changed
  prescriptionChange: function(value) {
    order.prescription = value
    el.orderForm.fadeIn()
    el.paymentForm.fadeIn()

    CheckoutWidget.updateOrderDesc()

    console.log(order)
  },

  // proceed to checkout with the selected frame
  selectFrame: function(frame) {
    order.frame = frame

    if (frame == "Ive") {
      order.size = "48"
    } else {
      el.sizeFormGroup.show()
    }

    CheckoutWidget.updateOrderDesc()

    CheckoutWidget.getGlassesEl(frame).fadeIn()

    el.purchaseFrame.fadeOut(function() {
      el.checkoutFrame.fadeIn()
    })
  },

  // go back to frame selection and reset
  goBack: function() {
    // todo: reset order details
    el.checkoutFrame.fadeOut(function() {
      el.purchaseFrame.fadeIn()

      el.glassesForm.trigger('reset')
      el.paymentForm.trigger('reset')
      el.orderForm.trigger('reset')

      el.allGlasses.hide()
      el.orderForm.hide()
      el.paymentForm.hide()
      el.lensOpticalFormGroup.hide()
      el.lensSunFormGroup.hide()
      el.prescriptionFormGroup.hide()
      el.sizeFormGroup.hide()

      // reset the order object
      order = _.clone(CheckoutWidget.order)
      console.log(order)
    })
  }
}


$(function() {
    if (!$('body').hasClass('buy')) return;

    $("#in-the-box-toggle").on('click', function(e) {
      if ($(e.target).hasClass('fa-plus')) {
        // remove plus and expand
        $(e.target).removeClass('fa-plus').addClass('fa-minus')
        $("#in-the-box").removeClass('contracted')

      } else {
        // remove minus and contract
        $(e.target).removeClass('fa-minus').addClass('fa-plus')
        $("#in-the-box").addClass('contracted')
      }
    })

    $("#tech-specs-toggle").on('click', function(e) {
      if ($(e.target).hasClass('fa-plus')) {
        // remove plus and expand
        $(e.target).removeClass('fa-plus').addClass('fa-minus')
        $("#specifications").removeClass('contracted')

      } else {
        // remove minus and contract
        $(e.target).removeClass('fa-minus').addClass('fa-plus')
        $("#specifications").addClass('contracted')
      }
    })

    CheckoutWidget.init()

    // $('.glasses').Stickyfill();

    // purchase path

    // var order = {}
    //
    // $("#utility-select").on('change', function() {
    //   order["utility"] = this.value
    //
    //   $('.glasses').fadeOut(function() {
    //     $("#" + order["frame"] + "-" + this.value).fadeIn()
    //   })
    //
    //   $("#lens-group").fadeIn()
    // })
    //
    // $("#lens-select").on('change', function() {
    //   console.log(this.value)
    //   $("#prescription-group").fadeIn()
    // })
    //
    // $("#prescription-select").on('change', function() {
    //   console.log(this.value)
    //   $("#new_preorder, #payment-form").fadeIn()
    // })
    //
    // $("#buy-ford").on('click', function() {
    //   order["frame"] = "Ford"
    //   $('#Ford-Optical').show()
    //
    //   $("#purchase").fadeOut(function() {
    //     $("#checkout").fadeIn()
    //   })
    // })
    //
    // $('#buy-ive').on('click', function() {
    //   order["frame"] = "Ive"
    //   $('#Ive-Optical').show()
    //
    //   $("#purchase").fadeOut(function() {
    //     $("#checkout").fadeIn()
    //   })
    // })
    //
    // $("#checkout-back").on('click', function() {
    //   $("#checkout").fadeOut(function() {
    //     $("#purchase").fadeIn()
    //     $('.glasses').hide()
    //   })
    // })

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
    // var preorderEngine = (function() {
    //   function Step(name, index, element, navElement, willDisplay, didComplete) {
    //     this.name = name
    //     this.index = index
    //     this.element = element
    //     this.navElement = navElement
    //     // willDisplay & didComplete are optional, check if they exist before calling them
    //     this.willDisplay = willDisplay
    //     this.didComplete = didComplete
    //
    //     // store a reference to this step on the element
    //     this.element.data('orderStep', this)
    //
    //     /**
    //     when users click on the element for this step, set the selection. Provide a handler in
    //     _didComplete to override and provide custom functionality
    //     */
    //     $('.select-' + name).on('click', function(e) {
    //       var step = $(this.closest('.step-container')).data('orderStep')
    //
    //       var selection = $(this).attr('data-' + step.name);
    //       _order[step.name] = selection;
    //
    //       if (step.didComplete != undefined) {
    //         step.didComplete()
    //       } else {
    //         _navigateForward()
    //       }
    //     })
    //
    //     this.complete = function(complete) {
    //       if (complete) {
    //         this.navElement.addClass('complete').html(_order[this.name])
    //       } else {
    //         this.navElement.removeClass('complete').html(this.name)
    //       }
    //     }
    //     this.current = function(current) {
    //       if (current) {
    //         this.navElement.addClass('current').html(this.name)
    //       } else {
    //         this.navElement.removeClass('current')
    //       }
    //     }
    //   }
    //
    //   // handlers for step.willDisplay
    //   var _willShow = {
    //     frame: function() {
    //       // show the right frames (depending on utility)
    //       $('.select-frame img').hide()
    //       $('.select-frame .' + _order['utility']).show()
    //     },
    //     lens: function() {
    //       var size = _order['frame'] == 'ive' ? tzukuri.models.ive.sizing.small : ''
    //       _order['size'] = size
    //
    //       // make sure prescription is always shown first
    //       $("#lens-type").show()
    //       $("#lens-size").hide()
    //
    //       // show the correct size selection images
    //       $('.select-size img').hide()
    //       $('.select-size .' + _order['utility']).show()
    //     },
    //     checkout: function() {
    //       $('#checkout-images img').hide()
    //       $('#checkout-images img.' + _order['frame'] + '.' + _order['utility']).show()
    //
    //       $('#utility-selection').html(_order['utility'])
    //       $('#frame-selection').html(_order['frame'])
    //       $('#lens-selection').html(_order['lens'])
    //       $('#size-selection').html(_order['size'] + "mm")
    //
    //       if (_order['lens'] == "prescription") {
    //           $('#total-selection').html(tzukuri.pricing.total + " AUD")
    //           $("#contact-prescription").show()
    //       } else {
    //           $('#total-selection').html(tzukuri.pricing.total + " AUD")
    //           $("#contact-prescription").hide()
    //       }
    //     }
    //   }
    //
    //   // handlers for step.didComplete
    //   var _didComplete = {
    //     lens: function() {
    //       if (_order['frame'] == 'ford') {
    //         $("#lens-type").fadeOut(function() {$("#lens-size").fadeIn()})
    //       } else {
    //         _navigateForward()
    //       }
    //     }
    //   }
    //
    //   var _steps = (function() {
    //     var _steps = []
    //     var _currentStep;
    //
    //     function _addStep(step) {
    //       _steps.push(step)
    //     }
    //
    //     function _getCurrentStep() {
    //       return _currentStep
    //     }
    //
    //     function _setCurrentStep(step) {
    //       _currentStep = step
    //     }
    //
    //     function _each(callback) {
    //       _.forEach(_steps, callback)
    //     }
    //
    //     function _next() {
    //       var i = _currentStep == null ? -1 : _currentStep.index
    //       return _steps[i + 1]
    //     }
    //
    //     function _stepWithName(name) {
    //       return _.find(_steps, function(step) {
    //         return step.name == name;
    //       })
    //     }
    //
    //     return {
    //       addStep: _addStep,
    //       each: _each,
    //       currentStep: _getCurrentStep,
    //       setCurrentStep: _setCurrentStep,
    //       stepWithName: _stepWithName,
    //       next: _next
    //     }
    //   })()
    //
    //   var _container
    //   var _nav
    //   var _order = {}
    //
    //   function _setOrderValues(values) {
    //     return _.merge(_order, values)
    //   }
    //
    //   function _setCurrentStep(next) {
    //     if (_steps.currentStep() == null) {
    //       // if we don't have a current step set this one
    //       if (next.willDisplay != undefined) next.willDisplay()
    //       next.element.removeClass('hidden')
    //     } else {
    //       // fade between the two steps
    //       if (next.willDisplay != undefined) next.willDisplay()
    //
    //       _steps.currentStep().element.addClass('hidden')
    //       next.element.removeClass('hidden')
    //
    //       // update the navigation
    //       _steps.each(function(step, i) {
    //         if (i == next.index) return;
    //         step.current(false)
    //         // step is only complete if index < the index we're about to display
    //         var complete = i < next.index ? true : false
    //         step.complete(complete)
    //       })
    //     }
    //     next.current(true)
    //     next.complete(false)
    //
    //     // scroll the indicator to the next nav element
    //     _moveNavIndicator(next.navElement)
    //
    //     _steps.setCurrentStep(next)
    //   }
    //
    //   function _moveNavIndicator(toEl) {
    //     var width = toEl.width()
    //     var leftOffset = toEl.offset().left
    //
    //     _nav.find('#nav-indicator').offset({
    //       left: leftOffset
    //     }).css('width', width + 'px')
    //   }
    //
    //   function _buildStepForNavEl(navEl, i) {
    //       var navEl = $(navEl)
    //       var name = navEl.attr('id')
    //       var el = _container.find('#step-' + name)
    //
    //       return new Step(name, i, el, $(navEl), _willShow[name], _didComplete[name])
    //   }
    //
    //   function _setPricing() {
    //     $('.pricing #deposit').html(tzukuri.pricing.deposit)
    //     $('.pricing #prescription').html(tzukuri.pricing.total)
    //     $('.pricing #non-prescription').html(tzukuri.pricing.total)
    //   }
    //
    //   function _handleApplePayAvailable(available) {
    //     if (available) {
    //         $('#apple-pay').show()
    //         $("#regular-pay").hide()
    //     } else {
    //         $('#regular-pay').show()
    //         $('#apple-pay').hide()
    //     }
    //   }
    //
    //   function _createPayment(token, code) {
    //     _order['token'] = token.id
    //     return $.post('/preorders', _order)
    //   }
    //
    //   function _navigateBack(stepName) {
    //     var step = _steps.stepWithName(stepName);
    //     _setCurrentStep(step)
    //   }
    //
    //   function _navigateForward() {
    //     _setCurrentStep(_steps.next())
    //   }
    //
    //   function _init(container, nav){
    //     // store the container and navigation objects
    //     _container = container
    //     _nav = nav
    //
    //     // check for apple pay available
    //     // Stripe.applePay.checkAvailability(_handleApplePayAvailable)
    //
    //     // create steps for each of the elements in the navigation
    //     _.forEach(_nav.find('a'), function(step, i) {
    //       var step = _buildStepForNavEl(step, i)
    //       _steps.addStep(step)
    //     })
    //
    //     // set pricing details
    //     _setPricing()
    //
    //     _navigateForward()
    //
    //     $(window).on('resize', function() {
    //       _moveNavIndicator(_steps.currentStep().navElement)
    //     })
    //   }
    //
    //   // PUBLIC API
    //   return {
    //     init: _init,
    //     setOrderValues: _setOrderValues,
    //     createPayment: _createPayment,
    //     navigateBack: _navigateBack,
    //     navigateForward: _navigateForward,
    //     order: _order
    //   }
    // })();
    //
    // $(document).ready(function() {
    //     preorderEngine.init($('#reserve'), $('#reserve-nav'))
    //
    //     // polyfill for position:sticky
    //     $('#glasses').Stickyfill();
    // });
    //
    // function handlePayment(token) {
    //     preorderEngine.createPayment(token).done(function(data, status) {
    //       showFormSpinner(false)
    //       if (data.success) {
    //           // show a success screen
    //            $("html, body").animate({ scrollTop: 0 }, "slow");
    //           $("#apple-pay, #regular-pay").fadeOut()
    //           $("#thank-you").fadeIn()
    //           $("#step-checkout h1").html("thanks for your reservation")
    //           $("#reserve-nav").fadeOut()
    //
    //           // send a booking event to google analytics
    //           ga('send', 'event', 'buy', 'purchase-complete', '', data.amount);
    //           fbq('track', 'Purchase', {value: data.amount, currency:'AUD'});
    //       } else {
    //           // there was an error creating the preorder/charging the card
    //           setFormError(data.errors)
    //       }
    //     }).fail(function() {
    //       // there was an error connecting to the server (timeout, etc.)
    //       setFormError("There was an error submitting your order, please try again. If this continues please contact Tzukuri support.")
    //       showFormSpinner(false)
    //     })
    // }
    //
    // // -------------------
    // // bindings
    // // -------------------
    //
    // // fixme: bit of a hack for the time being, need to be able to support sub-step choices properly
    // $('.select-size').on('click', function() {
    //   var size = $(this).attr('data-size');
    //   preorderEngine.setOrderValues({
    //     size: size
    //   })
    //   preorderEngine.navigateForward()
    // })
    //
    // // apple pay submission
    // $('.apple-pay-button-with-text').on('click', function(event) {
    //
    //     // create an apple pay session request and then redirect to a stripe charge
    //     var paymentRequest = {
    //         countryCode: 'AU',
    //         currencyCode: 'USD',
    //         total: {
    //             label: 'Tzukuri Pty. Ltd.',
    //             amount: tzukuri.pricing.nonprescription
    //         },
    //         requiredShippingContactFields: ['postalAddress', 'phone', 'email', 'name']
    //     }
    //
    //     var applePay = Stripe.applePay.buildSession(paymentRequest, function(result, completion) {
    //         var shippingContact = result.shippingContact
    //
    //         // contact details
    //         preorderEngine.setOrderValues({
    //           name: shippingContact.givenName + " " + shippingContact.familyName,
    //           email: shippingContact.emailAddress,
    //           phone: shippingContact.phoneNumber,
    //
    //           address_lines: shippingContact.addressLines.push(shippingContact.locality),
    //           country: shippingContact.country,
    //           state: shippingContact.administrativeArea,
    //           postal_code: shippingContact.postal_code,
    //         })
    //
    //         // create a payment and inform apple pay session when it is complete
    //         handlePayment(result.token).done(function(e) {
    //             if (e.success) {
    //                 completion(ApplePaySession.STATUS_SUCCESS)
    //             } else {
    //                 completion(ApplePaySession.STATUS_FAILURE)
    //             }
    //         }).fail(function() {
    //             completion(ApplePaySession.STATUS_FAILURE)
    //         })
    //     })
    //
    //     applePay.begin()
    // })
    //
    // // regular pay submission
    // $('#payment-form').submit(function(event) {
    //     event.preventDefault()
    //
    //     var shippingValid = validateShipping($('#new_preorder'))
    //     var paymentValid = validatePayment($('#payment-form'))
    //
    //     if (!shippingValid || !paymentValid) {
    //         // one or more form fields are invalid
    //         setFormError("Some fields are missing or invalid.")
    //         return
    //     };
    //
    //     // show the spinner to indicate network activity
    //     showFormSpinner(true)
    //
    //     Stripe.card.createToken($(this), function(status, token) {
    //         if (token.error) {
    //             setFormError(token.error.message)
    //             showFormSpinner(false)
    //         } else {
    //             handlePayment(token)
    //         }
    //     });
    // });
    //
    // // user clicks on a link in the preorder navigation
    // $('#reserve-nav a').on('click', function() {
    //     if (!$(this).hasClass('complete')) return;
    //     preorderEngine.navigateBack($(this).attr('id'))
    // })
    //
    // // simulate a submit click on enter press
    // $('#new_preorder').on("keypress", function(e) {
    //     if (e.keyCode == 13) {
    //         $("#reserve-submit").click()
    //     }
    // });
    //
    // // timer that keeps track of when user is typing
    // var coupon_timer;
    // var last_amount = tzukuri.pricing.total;
    //
    // $("#preorder_coupon").on("input", function() {
    //   // wait until finished typing and then submit a request to check if the coupon code exists
    //   clearTimeout(coupon_timer)
    //   coupon_timer = setTimeout(function() {
    //     // make a request to the API to check whether or not this coupon is legit
    //     var coupon = $("#preorder_coupon").val()
    //     var data = {"coupon": coupon}
    //
    //     $.post('/coupons', data).done(function(data) {
    //       // handle a value that means we don't have to charge the customer's card
    //
    //       if (data.type == "GIFT") {
    //         handleGift(data.token)
    //       } else if (data.type == "COUPON") {
    //         handleCoupon(data.token)
    //       } else {
    //         $("#preorder_coupon").tzAnimate('shake')
    //         updatePrice(tzukuri.pricing.total)
    //
    //         $("#gift-redeem").fadeOut(function() {
    //           $("#payment-form, #total-price").fadeIn()
    //         })
    //       }
    //
    //     })
    //
    //   }, 300)
    // })
    //
    // // prevent multiple clicks from firing events more than once while step-container is animating
    // $('.select-utility, .select-frame, .select-lens, .select-size').on('click', function(event) {
    //     if ($(this).closest(".step-container").is(":animated")) {
    //         event.stopImmediatePropagation()
    //     };
    // })
    //
    // // user is shown apple pay but wants to use the normal form
    // $('#ignore-apple-pay').on('click', function(event) {
    //     event.preventDefault()
    //
    //     $('#apple-pay').fadeOut(function() {
    //         $('#regular-pay').fadeIn()
    //     })
    // })
    //
    // $("#gift-redeem").on('click', function(event) {
    //   console.log('redeeming gift card')
    //
    //   var shippingValid = validateShipping($('#new_preorder'))
    //
    //   if (!shippingValid) {
    //       // one or more form fields are invalid
    //       setFormError("Some fields are missing or invalid.")
    //       return
    //   };
    //
    //   showFormSpinner(true)
    //
    //   $.post('/preorders', preorderEngine.order).done(function(data) {
    //     showFormSpinner(false)
    //
    //     $("html, body").animate({ scrollTop: 0 }, "slow");
    //      $("#apple-pay, #regular-pay").fadeOut()
    //      $("#thank-you").fadeIn()
    //      $("#step-checkout h1").html("thanks for your purchase")
    //      $("#reserve-nav").fadeOut()
    //   })
    // })
    //
    // // -------------------
    // // helper methods
    // // -------------------
    //
    // var handleGift = function(gift) {
    //   // replace payment information form with just a submit button
    //   $("#payment-form, #total-price").fadeOut(function() {
    //     $("#gift-redeem").fadeIn()
    //   })
    // }
    //
    // var handleCoupon = function(coupon) {
    //   var final_amount = tzukuri.pricing.total
    //   final_amount -= (coupon.discount / 100)
    //
    //   if (final_amount == last_amount) return
    //
    //   updatePrice(final_amount)
    // }
    //
    // // update the amount we say we are going to charge on the final view
    // var updatePrice = function(amount) {
    //   // update the values and pulse to bring focus
    //   $("#total-selection").html(amount + " AUD")
    //   $("#reserve-for").html("reserve for " + amount + " AUD")
    //
    //   $("#reserve-submit").tzAnimate('pulse')
    //   $("#total-selection").tzAnimate('pulse')
    //
    //   last_amount = amount
    // }
    //
    // // show a spinner in the submit button to indicate network activity
    // var showFormSpinner = function(showFormSpinner) {
    //   var hideEl = showFormSpinner ? "#reserve-submit" : "#submit-spinner"
    //   var showEl = showFormSpinner ? "#submit-spinner" : "#reserve-submit"
    //
    //   // clear the form error field if showing the spinner
    //   if (showFormSpinner) setFormError()
    //
    //   $(hideEl).hide()
    //   $(showEl).show()
    //
    //   $('#reserve-submit').prop('disabled', showFormSpinner)
    // }
    //
    // // add the error state to a form input
    // var addError = function(element) {
    //     $(element).addClass('error')
    //     return false
    // }
    //
    // // set an error message for the form, if message is not passed it will clear the error field
    // var setFormError = function(message) {
    //     if (message == null) {
    //       $("#error-messages").html("").hide()
    //       return;
    //     }
    //
    //     $('#error-messages').html(message).show()
    //     $('#reserve-submit, #gift-redeem').tzAnimate('shake')
    // }
    //
    // // validate the user's payment details
    // var validatePayment = function(form) {
    //     var valid = true
    //     var serialised = form.serializeObject()
    //
    //     form.find('input').removeClass('error')
    //
    //     var ccNumber = serialised["number"]
    //     var CVV = serialised["CVV"]
    //
    //     // if cc not valid
    //     if (ccNumber.length == 0) {
    //         // just checking it is not empty - letting stripe handle the actual validation
    //         valid = addError("#payment_ccNumber");
    //     }
    //
    //     // if cvv not valid?
    //     if (CVV == "") {
    //         valid = addError("#payment_cvv")
    //     }
    //
    //     return valid;
    // }
    //
    // // validate the user's shipping details
    // var validateShipping = function(form) {
    //     var valid = true
    //     var serialised = form.serializeObject()
    //
    //     form.find('input').removeClass('error')
    //
    //     // contact details
    //     var name = serialised["preorder[name]"]
    //     var phone = serialised["preorder[phone]"].replace(" ", "")
    //     var email = serialised["preorder[email]"]
    //
    //     // address details
    //     var address1 = serialised["preorder[address1]"]
    //     var address2 = serialised["preorder[address2]"]
    //     var postcode = serialised["preorder[postal_code]"]
    //     var state = serialised["preorder[state]"]
    //     var country = $('#preorder_country').val()
    //
    //     var coupon = serialised["preorder[coupon]"]
    //
    //     var ausPhoneNumbers = /^\({0,1}((0|\+61)(2|4|3|7|8)){0,1}\){0,1}(\ |-){0,1}[0-9]{2}(\ |-){0,1}[0-9]{2}(\ |-){0,1}[0-9]{1}(\ |-){0,1}[0-9]{3}$/;
    //
    //     if (name.length == 0) {
    //         valid = addError("#preorder_name")
    //     }
    //
    //     // check address 1 exists
    //     if (address1.length == 0) {
    //         valid = addError("#preorder_address1")
    //     }
    //
    //     // check postcode exists and is a number
    //     if (postcode.length != 4 || !/^\d+$/.test(postcode)) {
    //         valid = addError("#preorder_postal_code")
    //     }
    //
    //     if (state.length == 0) {
    //         valid = addError("#preorder_state")
    //     }
    //
    //     // check phone exists and is a valid australian phone number
    //     if (phone.length == 0 || !ausPhoneNumbers.test(phone)) {
    //         valid = addError("#preorder_phone")
    //     }
    //
    //     if (email.length == 0) {
    //         valid = addError("#preorder_email")
    //     }
    //
    //     if (valid) {
    //         // store the order details in the navigation object
    //         preorderEngine.setOrderValues({
    //           name: name,
    //           email: email,
    //           phone: phone,
    //           address_lines: [address1, address2],
    //           country: country,
    //           state: state,
    //           postal_code: postcode,
    //           coupon: coupon
    //         })
    //     }
    //
    //     return valid
    // }
});
