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

    // handle url params
    var frameParam = $.urlParam('frame')
    var utilityParam = $.urlParam('utility')
    var sentWithParams = false

    if (frameParam == "Ive" || frameParam == "Ford") {
      sentWithParams = true

      CheckoutWidget.selectFrame(frameParam)

      if (utilityParam == "Optical" || utilityParam == "Sun") {
          el.utilitySelect.val(utilityParam).trigger('change')
      }
    }
});
