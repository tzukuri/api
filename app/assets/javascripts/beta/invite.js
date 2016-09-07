$(function() {
    if (!$('body').hasClass('beta')) return;

    var birthdayTimeout;


    // -----------------------------
    // on page load binding
    // -----------------------------
    $(document).on("tzukuri.page.load", function() {
        // invite
        if ($('#beta-invite').attr('data-error')) {
            $('#form-error').tzAnimate('shake')
        }
    })

    $('#new_beta_user').on('input', function() {
        checkSubmit();
    })

    $('#eligible').on('click', function() {
        tzukuri.modal.show({
            modal: "#beta-eligible-modal",
            tint: "light",
            dismissable: true
        });
    })

    $('.register-now').on('click', function() {
        tzukuri.modal.show({
            modal: "#beta-register-modal",
            tint: "light",
            dismissable: true
        });
    })

    $("#beta_user_city").on('input', function() {
        // if there is nothing, or if we are making a change after the field has been selected
        if ($(this).val().length == 0 || selectedCity) {
            $("#beta_user_latitude").val("")
            $("#beta_user_longitude").val("")
            selectedCity = false
        } else {
            $(this).addClass('loading-spinner')
        }
    })

    // show the continue button to login when the user begins typing
    $('#beta_user_email').on('input', function(e) {
        if ($(this).val().length > 0 && $('#submit-btn').hasClass('disabled')) {
            $("#submit-btn").removeClass('disabled').tzAnimate('bounceIn')
        }
    })

    $('#beta-eligible-done').on('click', function() {
        tzukuri.modal.hideAll();
    })

    // prevent any input in the date field which isnt numeric or /
    $('#beta_user_birth_date').on('keypress', function(e) {
        if (e.metaKey) return;
        if ((e.which < 48 || e.which > 57) && e.which != 47) {
            e.preventDefault();
        }
    })

    $('#beta_user_birth_date').on('input', function(e) {
        // timeout that fires when the user has stopped typing for 350ms
        clearTimeout(birthdayTimeout);
        birthdayTimeout = setTimeout(function() {
            birthdayInputFinished($(e.target).val())
        }, 200);
    });



    var checkSubmit = function() {
        var complete = true;

        $('#new_beta_user').children("input").each(function(e) {
            if ($(this).val() == "") {
                return complete = false;
            }
        })

        if (complete) {
            // show the submit button
            $("#register-btn").removeClass('disabled').prop('disabled', false);

            // only animate in if coming from disabled state
            if ($('#register-btn').hasClass('disabled')) {
                $('#register-btn').tzAnimate('bounceIn').show();
            }

        } else {
            $("#register-btn").addClass('disabled').prop('disabled', true);
        }
    }

    // called when the user finishes typing in the birthday input field (for signup)
    var birthdayInputFinished = function(input) {
        var DATE_REGEX = /^\d{1,2}[/]\d{1,2}[/]\d{2,4}$/
        var hint = $("#birthday_hint").text()
        var hintText = "dd/mm/yyyy"
        var m = moment(input, 'D/M/YYYY')

        if (DATE_REGEX.test(input)) {
            if (m.isValid()) {
                var d = m.format("dddd, MMMM Do YYYY")

                $('#birthday_hint').fadeOut(function() {
                    $(this).text(d).tzAnimate('fadeIn').show()
                })
            }
        } else if (hint != hintText) {
            $("#birthday_hint").fadeOut(function() {
                $("#birthday_hint").html(hintText)
            }).fadeIn();
        }
    }

    // tzukuri photon API
    var PHOTON_API = "https://api.tzukuri.com/photon?q="
    var PHOTON_LIMIT = 3

    var cityQuery = function(request, response) {
        var apiURL = PHOTON_API + request.term + "&limit=" + PHOTON_LIMIT

        $.getJSON(apiURL, function(data) {
            var cities = [];

            // extract the features that we need
            _(data.features).forEach(function(feature) {

                var label = ''

                label += typeof feature.properties.name !== 'undefined' ? feature.properties.name + ', ' : ''
                label += typeof feature.properties.state !== 'undefined' ? feature.properties.state + ', ' : ''
                label += typeof feature.properties.country !== 'undefined' ? feature.properties.country : ''

                cities.push({
                    label: label,
                    value: feature.geometry.coordinates.toString()
                })
            });

            cities = _.uniqBy(cities, function(item, key, a) {
                return item.label;
            });

            $("#beta_user_city").removeClass('loading-spinner')

            response(cities)
        })
    }

    // keep track of whether the user has made a valid city selection or not
    var selectedCity = false;

    var selectCity = function(event, ui) {
        event.preventDefault()
        label = ui.item.label
        value = ui.item.value

        $("#beta_user_city").val(label);

        // split coordinates and assign
        var coordinates = value.split(",")
        $("#beta_user_latitude").val(coordinates[0])
        $("#beta_user_longitude").val(coordinates[1])

        selectedCity = true;
        checkSubmit();
    }

    var cityFocus = function(event, ui) {
        event.preventDefault()
    }

    var toggleEdges = function() {
        $('#beta_user_city').toggleClass('autocomplete-open')
    }

    $("#beta_user_city").autocomplete({
        source: cityQuery,
        select: selectCity,
        focus: cityFocus,
        open: toggleEdges,
        close: toggleEdges
    })

        // creating a new order if the user is selected
    $('#new_beta_user').on('ajax:success', function(e, data) {
        console.log(data)
        if (data.success) {
            window.location.replace(data.redirectURL)
        } else {
            $("#new_beta_user input").removeClass('error');

            _(data.errors).forEach(function(error, key) {
                $("#beta_user_" + key).addClass('error')
            });

            // populate the error messages
            $('#register-errors').html(data.error_messages.join(', '))
        }

    }).on('ajax:error', function(e, data) {
        console.log(data)
    });
});
