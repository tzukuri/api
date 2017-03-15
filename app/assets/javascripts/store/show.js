$(function() {
    console.log($('#selected'));
    console.log(images[0].url);
    $('#selected').html("<img src='" + images[0].url + "'>");

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
    });

});