$(function() {
    if (!$('body').hasClass('beta')) return;

    var currentQuestion;
    var design, colour, size;
    var birthdayTimeout;

    // -----------------------------
    // helper methods
    // -----------------------------

    // show a given question element and hide the rest
    var showQuestion = function(question) {
        // the first time this runs we don't need to fade out anything
        if (typeof currentQuestion != 'undefined') {
            currentQuestion.hide();
        }

        // fade in the next question
        question.tzAnimate('fadeIn').show()

        // set current question equal to the new question
        currentQuestion = question;
    }

    // when user is not selected, skip to the next survey question
    var skipQuestion = function() {
        // get the next question dom element that is answerable
        var nextEl = $(currentQuestion).nextAll("[data-answerable=true]").first()

        // if we're at the end of the questions, go back to the start
        if (_.isEmpty(nextEl)) {
            showQuestion($('[data-answerable=true]').first())
        } else {
            showQuestion(nextEl)
        }
    }

    // when user is selected, transition between elements
    var transitionFrom = function(fromEl) {
        // disable the parent class
        $(fromEl).parent().addClass('disabled')

        // transition from select colour to select design
        if ($(fromEl).hasClass('select-colour')) {
            if (colour == 'tortoise') {
                $("img#black").hide()
                $("img#tortoise").fadeIn()
            }

            $($("#frame-select .four.columns")[1]).removeClass('disabled')
            $("#beta_order_colour").val(colour)
            $("#colour-selection").html(colour)

            // transition from select size to shipping details
        } else if ($(fromEl).hasClass('select-size')) {
            $("#beta_order_size").val(size)
            $("#size-selection").html(size)

            // hide all checkout images and only show the selected one
            $('.checkout-img').hide()
            $('.checkout-img#' + design + '-' + colour).show()

            // todo: progress to the shipping details form
            $('#frame-select').fadeOut(function() {
                $('#order-details').fadeIn();
            });

            // transition from select design to select size
        } else if ($(fromEl).hasClass('select-design')) {
            $($("#frame-select .four.columns")[2]).removeClass('disabled')

            $("#beta_order_frame").val(design)
            $("#frame-selection").html(design)
        }
    }

    // given a list of questions that are able to be answered, update the UI to reflect the server state
    var updateAnswerables = function(answerables) {
        // iterate through all the question elements and update their answerable value
        _($('.question')).forEach(function(el, i) {
            $(el).attr('data-answerable', _.includes(answerables, i + 1))
        });

        // hide all the elements with answerable = false
        $("[data-answerable=false]").hide()

        // if there are no more answerable elements
        if (_.isEmpty($('[data-answerable=true]'))) {
            // hide all questions and remove skip button
            $('.question').hide()
            $("#questions-complete").removeClass('hidden')
            $("#skip-questions").addClass('hidden')
        } else {
            var nextEl = $(currentQuestion).nextAll("[data-answerable=true]").first()
            showQuestion(nextEl)
        }
    }

    // given a new score and percentage update the UI to reflect the server state
    var updateScore = function(score, percentage) {
        $("#score").fadeOut(500, function() {
            $("#score").html(score + " points").tzAnimate('pulse').fadeIn()
        })
        $("#percentage").html(percentage + "% chance")
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
            $('#birthday_hint').fadeOut()
        }
    }

    // -----------------------------
    // on page load binding
    // -----------------------------
    $(document).on("tzukuri.page.load", function() {

        // shake the email input if there is an error logging in
        if ($('#login-container').attr('data-error')) {
            $('#beta_user_email').tzAnimate('shake')
        }

        showQuestion($('[data-answerable=true]').first())
    })

    // -----------------------------
    // dom element bindings
    // -----------------------------
    $('#new_beta_order').on('input', function() {
        var complete = true;

        $(this).children("input").each(function(e) {
            if ($(this).attr('id') == 'beta_order_address2') return true;
            if ($(this).val() === "") {
                return complete = false;
            }
        })

        if (complete && !$("#submit-btn").is(":visible")) {
            // show the submit button
            $("#submit-btn").tzAnimate('bounceIn').show();
        }
    })

    // pulse on mouseover
    $('.select-colour, .select-design, .select-size').on('mouseover', function() {
        if ($(this).parent().hasClass('disabled')) return;
        $(this).tzAnimate('pulse')
    })

    // handle click on frame select elements
    $('.select-colour, .select-design, .select-size').on('click', function() {
        if ($(this).parent().hasClass('disabled')) return;

        // set size, colour or design depending on which is available
        size = $(this).attr('data-size') || size
        colour = $(this).attr('data-colour') || colour
        design = $(this).attr('data-design') || design

        transitionFrom(this)
    })

    // pulse the social buttons on mouseover
    $(".social-button .content").on("mouseover", function() {
        $(this).tzAnimate('pulse')
    })

    $("#skip-questions").on("click", function() {
        skipQuestion()
    })

    // automatically select the contents of the input when the unique link is clicked
    $("#unique-link").on("click", function() {
        $(this).select()
    })

    // show the continue button to login when the user begins typing
    $('#beta_user_email').on('input', function(e) {
        if ($(this).val().length > 0 && !$("#submit-btn").is(":visible")) {
            $("#submit-btn").tzAnimate('bounceIn').show()
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
        }, 350);
    });

    // -----------------------------
    // ajax response handlers
    // -----------------------------

    // creating a new response to a survey question
    $('.new_beta_response').on('ajax:success', function(e, data) {
        if (data.success) {
            updateAnswerables(data.answerable_questions)
            updateScore(data.score, data.percentage_chance)
        } else {
            // todo: handle the error state
        }
    }).on('ajax:error', function(e, data) {
        // todo: handle the error state
    });

    // creating a new order if the user is selected
    $('.new_beta_order').on('ajax:success', function(e, data) {
        console.log(data)

        if (data.success) {
            // fadeout and then reload the view
            $("#selected-container").fadeOut(function() {
                location.reload();
            })
        } else {
            $("#new_beta_order input").removeClass('error');
            _(data.errors).forEach(function(error, key) {
                $("#beta_order_" + key).addClass('error')
            });

            $("#submit-btn").tzAnimate('shake');
        }

    }).on('ajax:error', function(e, data) {
        $("#error-messages").html(e)
    });

});
