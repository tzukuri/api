$(function() {
    if (!$('body').hasClass('beta')) return;

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

    $("#beta_user_city").on('input', function() {
        if ($(this).val().length == 0) {
            $("#beta_user_latitude").val("")
            $("#beta_user_longitude").val("")
        } else {
            $(this).addClass('loadinggif')
        }
    })

    var checkSubmit = function() {
        var complete = true;

        $('#new_beta_user').children("input").each(function(e) {
            if ($(this).val() === "") {
                return complete = false;
            }
        })

        if (complete && !$("#register-btn").is(":visible")) {
            // show the submit button
            $("#register-btn").tzAnimate('bounceIn').show();
        }
    }

    // photon API details
    var PHOTON_API = "http://photon.komoot.de/api/?q="
    var PHOTON_LIMIT = 4

    var cityQuery = function(request, response) {
        $.getJSON(`${PHOTON_API}${request.term}&limit=${PHOTON_LIMIT}`, function(data) {
            var cities = [];

            // extract the features that we need
            _(data.features).forEach(function(feature) {
                cities.push({
                    label: `${feature.properties.name}, ${feature.properties.state}, ${feature.properties.country}`,
                    value: feature.geometry.coordinates.toString()
                })
            });

            $("#beta_user_city").removeClass('loadinggif')

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
