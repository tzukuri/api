var el, couponTimer, order, CheckoutWidget = {

  elements: {
    utilitySelect: $("#utility-select"),
    lensSelectOptical: $("#lens-select-optical"),
    lensSelectSun: $('#lens-select-sun'),
    prescriptionSelect: $('#prescription-select'),
    sizeSelect: $('#size-select'),

    buyIveSun: $("#ive-sun #buy"),
    buyIveOptical: $("#ive-optical #buy"),
    buyFordSun: $("#ford-sun #buy"),
    buyFordOptical: $("#ford-optical #buy"),

    backButton: $("#checkout-back"),

    checkoutFrame: $('#checkout'),

    lensSunFormGroup: $("#lens-group-sun"),
    lensOpticalFormGroup: $('#lens-group-optical'),
    prescriptionFormGroup: $("#prescription-group"),
    sizeFormGroup: $('#size-group'),
    orderForm: $("#new_preorder"),
    paymentForm: $("#payment-form"),
    glassesForm: $("#glasses-form"),
    couponInput: $("#preorder_coupon"),
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
    prescription_method: undefined,

    name: undefined,
    email: undefined,
    phone: undefined,

    address_lines: undefined,
    state: undefined,
    postal_code: undefined,
    country: undefined,

    token: undefined
  },

  pricing: {
    displayed: tzukuri.pricing.nonprescriptionPrice,
    frame: tzukuri.pricing.nonprescriptionPrice,
    discount: 0.0
  },

  init: function() {
    el = this.elements
    order = _.clone(this.order)
    pricing = _.clone(this.pricing);

    this.bindUIActions()

    el.checkoutFrame.fadeIn()
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

    el.couponInput.on('input', function() {
      CheckoutWidget.checkCoupon(this.value)
    })

    // bind actions to buy clicks
    el.buyIveSun.on('click', function() {
      CheckoutWidget.selectModel('Ive', 'Sun')
    })

    el.buyIveOptical.on('click', function() {
      CheckoutWidget.selectModel('Ive', 'Optical')
    })

    el.buyFordSun.on('click', function() {
      CheckoutWidget.selectModel('Ford', 'Sun')
    })

    el.buyFordOptical.on('click', function() {
      CheckoutWidget.selectModel('Ford', 'Optical')
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
      order.coupon = coupon
    }

    console.log(order)

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
    } else {
      try {
        fbq('track', 'AddPaymentInfo');
      } catch(e) {}
    }

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

          var order = data.preorder
          
          if (data.success) {
            ga('send', 'event', 'buy', 'purchase-complete');

            ga('ecommerce:addItem', {
              'id': order.id,
              'name': order.frame+ " " + order.utility + " " + order.size + " " + order.lens,
              'sku': data.sku,
              'category': 'unlosable-glasses',
              'price': data.amount,
              'quantity': '1'
            });

            ga('ecommerce:send');

            try {
              fbq('track', 'Purchase', {
                content_ids: [data.sku],
                content_type: 'product',
                value: data.amount,
                currency: 'AUD'
              });
            } catch(e) {}

            try{ __adroll.record_user({"adroll_segments": "jl6pndx8"})} catch(err) {}

            el.orderDiv.fadeOut(function() {
              el.orderCompleteDiv.fadeIn()
            })
          } else {
            CheckoutWidget.setFormError("An error occured while submitting your order.")
            CheckoutWidget.showFormSpinner(false)
          }
        }).fail(function(error) {
          CheckoutWidget.setFormError("An error occured while submitting your order.")
          CheckoutWidget.showFormSpinner(false)
        })
      }
    })
  },

  // returns the element that contains the glasses image
  getGlassesEl: function(frame, utility) {
    if (utility == "Optical") {
      return frame == "Ive" ? el.iveOptical : el.fordOptical
    } else if (utility == "Sun") {
      return frame == "Ive" ? el.iveSun : el.fordSun
    }
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
      order.prescription_method = null
      el.prescriptionFormGroup.fadeOut()
      el.orderForm.fadeIn()
      el.paymentForm.fadeIn()
      el.prescriptionSelect.prop('selectedIndex', 0);
      pricing.frame = tzukuri.pricing.nonprescriptionPrice;
    } else {
      el.prescriptionFormGroup.fadeIn()
      pricing.frame = tzukuri.pricing.prescriptionPrice;
    }

    CheckoutWidget.updatePrice();
  },

  // called when the prescription delivery select is changed
  prescriptionChange: function(value) {
    order.prescription_method = value
    el.orderForm.fadeIn()
    el.paymentForm.fadeIn()

    CheckoutWidget.updateOrderDesc()
  },

  selectModel: function(frame, utility) {
    order.frame = frame
    order.utility = utility

    if (frame == "Ive") {
      order.size = "48"
    } else if (frame == "Ford") {
      el.sizeFormGroup.show()
    }

    if (utility == "Optical") {
      el.lensOpticalFormGroup.show()
    } else if (utility == "Sun") {
      el.lensSunFormGroup.show()
    }

    $(".action-bar").addClass('no-display')

    CheckoutWidget.updateOrderDesc()
    CheckoutWidget.getGlassesEl(frame, utility).fadeIn()

    el.checkoutFrame.fadeIn()
  },

  handleCoupon: function(coupon) {
    pricing.discount = coupon.discount;
    CheckoutWidget.updatePrice();
  },

  // update the price on the view
  updatePrice: function() {
      var price = pricing.frame;
      if (pricing.discount > 0.0) {
          price -= (pricing.discount / 100);
      }

      if (price == pricing.displayed) {
          return;
      }

      // update the values and pulse to bring focus
      $("#total-selection").html(price + " AUD");
      $("#reserve-for").html("reserve for " + price + " AUD");

      $("#reserve-submit").tzAnimate('pulse');
      $("#total-selection").tzAnimate('pulse');

      pricing.displayed = price;
  },

  // make a request to the server to validate the coupon
  checkCoupon: function(coupon) {
    // wait until finished typing then submit request
    clearTimeout(couponTimer)

    couponTimer = setTimeout(function() {
      var data = {"coupon": coupon}

      $.post('/coupons', data).done(function(data) {
        if (data.type == "COUPON") {
          // handle coupon
          CheckoutWidget.handleCoupon(data.token)
        } else {
          // no coupon
          pricing.discount = 0.0;
          CheckoutWidget.updatePrice();
        }
      })
    }, 300)
  }
}

$(function() {
    $("#in-the-box").on('click', function(e) {
      if ($("#in-the-box-toggle").hasClass('fa-plus')) {
        // remove plus and expand
        $("#in-the-box-toggle").removeClass('fa-plus').addClass('fa-minus')
        $("#in-the-box").removeClass('contracted')

      } else {
        // remove minus and contract
        $("#in-the-box-toggle").removeClass('fa-minus').addClass('fa-plus')
        $("#in-the-box").addClass('contracted')
      }
    })

    $("#specifications").on('click', function(e) {
      if ($("#tech-specs-toggle").hasClass('fa-plus')) {
        // remove plus and expand
        $("#tech-specs-toggle").removeClass('fa-plus').addClass('fa-minus')
        $("#specifications").removeClass('contracted')

      } else {
        // remove minus and contract
        $("#tech-specs-toggle").removeClass('fa-minus').addClass('fa-plus')
        $("#specifications").addClass('contracted')
      }
    })

    // handle url params
    var frameParam = $.urlParam('frame');
    var utilityParam = $.urlParam('utility');

    // facebook "add to cart" followed immediately by initiating checkout
    var sku = frameParam.toUpperCase();
    sku += (utilityParam == 'Optical') ? '-OP' : '-SU';
    sku += '-RE-NP';

    fbq('track', 'AddToCart', {
      content_ids: [sku],
      content_type: 'product',
      value: 385.0,
      currency: 'AUD'
    });

    fbq('track', 'InitiateCheckout');

    CheckoutWidget.init();
    CheckoutWidget.selectModel(frameParam, utilityParam);
});
