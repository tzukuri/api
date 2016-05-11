// bind hamburger click
$(document).on("click", "#hamburger", function() {
  event.preventDefault()
  $('header menu').toggleClass('showing')
})
