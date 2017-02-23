$(function() {
  $("#try-form").on('submit', function(e) {
    $("#try-form button").html("booking...").addClass("disabled").prop("disabled", true)
  })

  $('#try-form').on('ajax:success', function(e, data) {
    var allow = data.allow
    var valid_email = data.valid_email
    var city = data.city
    var name = data.name.replace(" ", "%20")
    var email = data.email

    // inject calendly widget to prevent from entering name and email again
    var calendlyURL = "https://calendly.com/tzukuri/personal-fitting?name=" + name + "&email=" + email
    var calendly = $("<div class=\"calendly-inline-widget\" data-url=" + calendlyURL + " style=\"min-width:320px;height:750px;\"></div>")

    // reset button
    $("#try-form button").html("book now").removeClass("disabled").prop("disabled", false)

    if(!valid_email) {
      // todo: make them reenter their email
      console.log('invalid email address')
      $("#try-form #email").addClass('error').tzAnimate('shake')
      $("#try-form .messages").text("Please enter a valid email address")
      return
    }

    // send a booking event to google analytics and facebook
    ga('send', 'event', 'try-on', 'book');
    fbq('track', 'Lead');

    if (allow) {
      // inject calendly and initialise
      $("#calendly").append(calendly)
      Calendly.initInlineWidgets()

      $("#gate").fadeOut(function() {
        $("#calendly").fadeIn()
      })
    } else {
      // todo: show coming soon
      console.log('denying personal try on booking')
      $("#gate, #calendly").fadeOut(function() {
        $("#coming-soon").fadeIn()
      })
    }
  }).on('ajax:error', function(e, data) {
    console.log(data)
    $("#try-form button").html("book now").removeClass("disabled").prop("disabled", false)
  });
});
