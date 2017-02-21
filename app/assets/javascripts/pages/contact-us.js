$(function() {
  $("#new_enquiry").on('submit', function(e) {
    $("#enquiry_name, #enquiry_email, #enquiry_content").removeClass('error')
    $("#new_enquiry .messages").text("")

    $("#new_enquiry [type=submit]").val("sending...").addClass("disabled").prop("disabled", true)
  })

  $('#new_enquiry').on('ajax:success', function(e, data) {
    if(data.success) {

      $("#enquiry").fadeOut(function() {
        $("#thanks").fadeIn()
      })

    } else {
      $("#new_enquiry .messages").text(data.full_errors.join(", "))
      Object.keys(data.errors).forEach(function(key, index) {
        $("#enquiry_" + key).addClass('error').tzAnimate('shake')
      })
    }

    // reset button
    $("#new_enquiry [type=submit]").val("send enquiry").removeClass("disabled").prop("disabled", false)

  }).on('ajax:error', function(e, data) {
    $("#new_enquiry .messages").text("There was an error submitting your enquiry. Please try again.")
    $("#new_enquiry [type=submit]").val("send enquiry").removeClass("disabled").prop("disabled", false)
  });
});
