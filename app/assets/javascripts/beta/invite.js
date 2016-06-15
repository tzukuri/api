$(function() {
    if (!$('body').hasClass('beta')) return;

    var birthdayTimeout;

    // var crossFade = (function() {
    //     var FADE_INTERVAL = 6000;
    //     var FADE_TIME = 1000;

    //     var c = {}

    //     c.start = function(imageContainer) {
    //         // change image every FADE_INTERVAL seconds
    //         setInterval(c.changeImage.bind(null, imageContainer), FADE_INTERVAL)
    //     }

    //     c.changeImage = function(imageContainer) {
    //         var top = $(imageContainer).children('.top')
    //         top.removeClass('top')

    //         // there is a next element, it becomes the new one
    //         if (top.next().length > 0) {
    //             setTimeout(function() {
    //                 top.next().addClass('top')
    //             }, FADE_TIME)

    //         // otherwise loop back to the start
    //         } else {
    //             setTimeout(function() {
    //                 $(imageContainer).children().first().addClass('top')
    //             }, FADE_TIME)
    //         }
    //     }

    //     return c;
    // }());

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

    $('#register-now').on('click', function() {
        tzukuri.modal.show({
            modal: "#beta-register-modal",
            tint: "light",
            dismissable: true
        });
    })

    $("#beta_user_city").on('input', function() {
        if ($(this).val().length == 0) {
            $("#beta_user_latitude").val("")
            $("#beta_user_longitude").val("")
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
            if ($(this).val() === "") {
                return complete = false;
            }
        })

        if (complete && $('#register-btn').hasClass('disabled')) {
            // show the submit button
            $("#register-btn").removeClass('disabled').tzAnimate('bounceIn').show();
        }
    }


    // called when the user finishes typing in the birthday input field (for signup)
    var birthdayInputFinished = function(input) {
        var DATE_REGEX = /^\d{1,2}[/]\d{1,2}[/]\d{4}$/
        var hint = $("#birthday_hint").text()
        var hintText = "dd/mm/yyyy"
        var m = moment(input, "DD/MM/YYYY")

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

    // photon API details
    var PHOTON_API = "http://photon.komoot.de/api/?q="
    var PHOTON_LIMIT = 3

    var cityQuery = function(request, response) {
        console.log("---- REQUEST ----")
        $.getJSON(`${PHOTON_API}${request.term}&limit=${PHOTON_LIMIT}`, function(data) {
            var cities = [];

            // extract the features that we need
            _(data.features).forEach(function(feature) {

                var label = ''

                // typeof metadata_title  !== "undefined" ?  "<title>" + metadata_title + "</title>\n"                             : "" )

                label += typeof feature.properties.name !== 'undefined' ? feature.properties.name + ', ' : ''
                label += typeof feature.properties.state !== 'undefined' ? feature.properties.state + ', ' : ''
                label += typeof feature.properties.country !== 'undefined' ? feature.properties.country : ''

                // label += feature.properties.name + ", " || ''
                // label += feature.properties.state + ", " || ''
                // label += feature.properties.country + ", " || ''

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

    var selectCity = function(event, ui) {
        event.preventDefault()
        label = ui.item.label
        value = ui.item.value

        $("#beta_user_city").val(label);

        // split coordinates and assign
        var coordinates = value.split(",")
        $("#beta_user_latitude").val(coordinates[0])
        $("#beta_user_longitude").val(coordinates[1])

        checkSubmit();
    }

    var cityFocus = function(event, ui) {
        event.preventDefault()
    }

    $("#beta_user_city").autocomplete({
        source: cityQuery,
        select: selectCity,
        focus: cityFocus
    })
});
