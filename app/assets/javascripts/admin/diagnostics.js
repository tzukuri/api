$(function() {
    if (!$('body').hasClass('admin_diagnostics')) return

    // expand button bindings
    $('.expand').on('click', function(e) {
      e.preventDefault()
      var start = $(this).attr('data-start')
      var end = $(this).attr('data-end')
      var token = $('#diagnostic-timeline').attr('data-token')
      var date = $('#diagnostic-timeline').attr('data-date')

      // remove the button and it's parent row
      $(this).parent().parent().fadeOut()

      // make an GET request to retrieve all entries between these two times (not including)
      $.post("/admin/diagnostics/expand", {start_index: start, end_index: end, token: token, date: date}, function(data) {
        // get the start element so we know where to add entries from
        var startEl = $('.item-' + start)

        $.each(data.entries.reverse(), function(index, entry) {
          var template = templateForEntry(entry)
          $(template).insertAfter(startEl)
        })
      });
    })

    // decide which template to build based on the entry class
    var templateForEntry = function(entry) {
      switch(entry.class) {
        case "Tzukuri::LocationValue":
          return locationTemplate(entry)
        default:
          return genericTemplate(entry)
      }
    }

    // ------- template builders --------
    var locationTemplate = function(entry) {
      // return a location value
      var t = document.querySelector('template#entry-location').content;
      var clone = document.importNode(t, true);

      $(clone).find('.entry-time').html(entry.time)
      $(clone).find('.entry-location').html(entry.value.latitude + ", " + entry.value.longitude)
      $(clone).find('.entry-accuracy').html(entry.value.accuracy + " metres")
      $(clone).find('.entry-timestamp').html(entry.value.ts)

      return clone
    }

    var genericTemplate = function(entry) {
      var t = document.querySelector('template#entry-generic').content;
      var clone = document.importNode(t, true);

      $(clone).find(".entry-type").html(entry.type.toUpperCase())
      $(clone).find(".entry-value").html(entry.value)
      $(clone).find(".entry-time").html(entry.time)

      return clone;
    }

});
