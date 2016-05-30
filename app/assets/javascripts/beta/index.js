$(function() {
    if (!$('body').hasClass('beta')) return;

    var currentQuestion;

    // -----------------------------
    // helper methods
    // -----------------------------
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

    // var updateProgress = function() {
    //     var socialConnected = $('.social-button.connected').length
    //     var questionCompleted = 10 - $('.question').length

    //     var total = 110

    //     var pointsCompleted = (socialConnected * 20) + (questionCompleted * 5)
    //     var percentComplete = (pointsCompleted / total) * 100

    //     $(".progress-bar").css("width", percentComplete + "%")
    // }

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

    // catch the ajax response from the beta response form (answering questions)
    $('.new_beta_response').on('ajax:success', function(e, data) {
        console.log(data)
        if (data.success) {
            // update the question state and display correct questionss
            updateAnswerables(data.answerable_questions)

            // update the score and the percentage chance in the view
            updateScore(data.score, data.percentage_chance)
        } else {
            // todo: handle the error state
        }
    }).on('ajax:error', function(e, data) {
            // todo: handle the error state
    });

    var updateAnswerables = function(answerables) {
        // iterate through all the question elements and update their answerable value
        _($('.question')).forEach(function(el, i) {
          $(el).attr('data-answerable', _.includes(answerables, i+1))
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

    var updateScore = function(score, percentage) {
        $("#score").fadeOut(500, function() {
            $("#score").html(score + " points").tzAnimate('pulse').fadeIn()
        })

        $("#percentage").html(percentage + "% chance")
    }

    // -----------------------------
    // birthday input field
    // -----------------------------
    var timeoutPromise;

    // prevent any input in the date field which isnt numeric or /
    $('#beta_user_birth_date').on('keypress', function(e) {
        if (e.metaKey) return;
        if ((e.which < 48 || e.which > 57) && e.which != 47) {
            e.preventDefault();
        }
    })

    $('#beta_user_birth_date').on('input', function(e) {
        // timeout that fires when the user has stopped typing for 350ms
        clearTimeout(timeoutPromise);
        timeoutPromise = setTimeout(function() {
            doneTyping($(e.target).val())
        }, 350);
    });

    var doneTyping = function(input) {
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

});
