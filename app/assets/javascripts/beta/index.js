$(function() {
    if (!$('body').hasClass('beta')) return;

    var currentQuestion;
    var design, size;

    // retrieve required attributes from DOM attributes
    var score = parseInt($('#beta-index').attr('data-score'))
    var responsePoints = parseInt($('#beta-index').attr('data-response-points'))
    var topThreshold = parseInt($('#beta-index').attr('data-top-threshold'))
    var numThresholdUsers = parseInt($('#beta-index').attr('data-threshold-users'))

    var modelSizing = {
        ive: {
            small: '48mm',
            large: '50.5mm'
        },
        ford: {
            small: '49mm',
            large: '51.5mm'
        }
    }

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

        if ($(fromEl).hasClass('select-size')) {
            $("#beta_order_size").val(size)
            $("#size-selection").html(size)

            // hide all checkout images and only show the selected one
            $('.checkout-img').hide()
            $('.checkout-img#' + design + '-black').show()

            // progress to the shipping details form
            $('#frame-select').fadeOut(function() {
                $('#order-details').fadeIn();
            });

            // transition from select design to select size
        } else if ($(fromEl).hasClass('select-design')) {
            $($("#frame-select .columns")[1]).removeClass('disabled')

            // update the size values
            $('.select-size#large').html(modelSizing[design].large)
            $('.select-size#small').html(modelSizing[design].small)

            $('.select-size#large').attr('data-size', modelSizing[design].large)
            $('.select-size#small').attr('data-size', modelSizing[design].small)

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
            $('#question-header').hide();
            $('#questions-complete').removeClass('hidden')
        } else {
            var nextEl = $(currentQuestion).nextAll("[data-answerable=true]").first()
            if (_.isEmpty(nextEl)) nextEl = $("[data-answerable=true]").first()
            showQuestion(nextEl)

            // if there is one question remaining, hide the skip button
            if ($('[data-answerable=true]').length == 1) {
                $("#skip").addClass('hidden')
            }
        }
    }

    var updateScoreView = function() {
        $("#points-amount").fadeOut(500, function() {
            $("#points-amount").html(score).tzAnimate('pulse').fadeIn()
        })

        var scoreDiff = topThreshold - score;

        if (scoreDiff > 0) {
            $('#incentive').html('<p><span class="bold">+<span id="score_diff">' + scoreDiff +'</span> points required</span><br/>to enter top 100</p>')
        } else {
            $('#incentive').html('<p>You\'re in the top ' + numThresholdUsers + '</p>')
        }
    }

    // start polling
    var getLatestScore = function() {
        $.get('/beta_users/latest_score', function(data) {
            console.log(data)

            if (data.clean) {
                // there is no updates left in the queue for this user
                score = data.score
            } else {
                // try again in 2 seconds
                setTimeout(getLatestScore, 2000)
            }
        });
    }

    // -----------------------------
    // on page load binding
    // -----------------------------
    $(document).on("tzukuri.page.load", function() {

        // shake the email input if there is an error logging in
        if ($('#login-container').attr('data-error')) {
            $('#beta_user_email').tzAnimate('shake')
        }

        // if the user is logged in and looking at the details view show the
        // beta modal if this is the first time
        if ($('#details-container').length > 0) {
            storage = window.localStorage;

            if (storage.getItem('betaAlreadyVisited') === null || storage.getItem('betaAlreadyVisited') == false) {

                try {
                    storage.setItem('betaAlreadyVisited', true);
                } catch (error) {
                    // can't set localstorage (probably in private mode)
                    // console.log(error)
                }

                tzukuri.modal.show({
                    modal: "#beta-modal",
                    tint: "light",
                    dismissable: true
                });
            }

            // update the number of days remaining
            var end = moment([2016, 6, 28])
            var daysRemaining = moment().diff(end, 'days') * -1
            $('#days-remain').html(daysRemaining)

            // trigger score updates
            // getLatestScore();

            // show the first answerable question
            showQuestion($('[data-answerable=true]').first())
        }
    })

    // -----------------------------
    // dom element bindings
    // -----------------------------

    $('#need-help').on('click', function() {
        tzukuri.modal.show({
            modal: "#beta-modal",
            tint: "light",
            dismissable: true
        });
    })

    $('#beta-modal-done').on('click', function() {
        tzukuri.modal.hideAll();
    })

    $('#new_beta_order').on('input', function() {
        var complete = true;

        $(this).children("input").each(function(e) {
            if ($(this).attr('id') == 'beta_order_address2') return true;
            if ($(this).val() === "") {
                return complete = false;
            }
        })

        if (complete && $("#submit-btn").hasClass('disabled')) {
            // show the submit button
            $("#submit-btn").removeClass('disabled').tzAnimate('bounceIn')
        }
    })

    $("#shipping-back").on('click', function() {
        $('#order-details').fadeOut(function() {
            $('#frame-select').fadeIn();
        });

        $($("#frame-select .columns")[0]).removeClass('disabled')
    })

    // pulse on mouseover
    $('.select-design>img, .select-size').on('mouseover', function() {
        if ($(this).parent().hasClass('disabled')) return;
        $(this).tzAnimate('pulse')
    })

    // handle click on frame select elements
    $('.select-design, .select-size').on('click', function() {
        if ($(this).parent().hasClass('disabled')) return;

        // set size or design depending on which is available
        size = $(this).attr('data-size') || size
        design = $(this).attr('data-design') || design

        transitionFrom(this)
    })

    $("#skip").on("click", function() {
        skipQuestion()
    })

    // automatically select the contents of the input when the unique link is clicked
    $("#link").on("click", function() {
        // for mobile safari
        this.setSelectionRange(0, this.value.length)
    })

    $('.new_beta_user').on('input propertychange', function() {
        var complete = true;

        $(this).children('input').each(function() {
            if ($(this).val() === '') {
                return complete = false;
            }
        })

        if (complete && $('#submit-btn').hasClass('disabled')) {
            $('#submit-btn').removeClass('disabled').tzAnimate('bounceIn').show();
        }
    })

    // -----------------------------
    // ajax response handlers
    // -----------------------------

    // creating a new response to a survey question
    $('.new_beta_response').on('ajax:success', function(e, data) {
        if (data.success) {
            updateAnswerables(data.answerable_questions)
            // getLatestScore();
        } else {
            // skip to the next question
            skipQuestion();
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
