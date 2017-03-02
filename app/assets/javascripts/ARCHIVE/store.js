$(function() {
  var frames = {
    atticus: {
      sub: 'inspired by Atticus Finch.',
      desc: 'The balance of roundness and depth complements the dimensions and angularity of most longer faces.',

      black: {
        side: "<%= image_path('frames/atticus/black-side.jpg') %>",
        front: "<%= image_path('frames/atticus/black-front.jpg') %>",
        angle: "<%= image_path('frames/atticus/black-angle.jpg') %>",
        male: "<%= image_path('frames/atticus/m.jpg') %>",
        female: "<%= image_path('frames/atticus/f.jpg') %>"
      },

      tortoise: {
        side: "<%= image_path('frames/atticus/tortoise-side.jpg') %>",
        front: "<%= image_path('frames/atticus/tortoise-front.jpg') %>",
        angle: "<%= image_path('frames/atticus/tortoise-angle.jpg') %>",
        male: "<%= image_path('frames/atticus/m.jpg') %>",
        female: "<%= image_path('frames/atticus/f.jpg') %>"
      },
    },

    fitzgerald: {
      sub: 'inspired by John Fitzgerald Kennedy.',
      desc: 'Softer angles and horizontal planes to add subtle definition to cheekbones. A classic and understated style.',

      black: {
        side: "<%= image_path('frames/fitzgerald/black-side.jpg') %>",
        front: "<%= image_path('frames/fitzgerald/black-front.jpg') %>",
        angle: "<%= image_path('frames/fitzgerald/black-angle.jpg') %>",
        male: "<%= image_path('frames/fitzgerald/m.jpg') %>",
        female: "<%= image_path('frames/fitzgerald/f.jpg') %>"
      },

      tortoise: {
        side: "<%= image_path('frames/fitzgerald/tortoise-side.jpg') %>",
        front: "<%= image_path('frames/fitzgerald/tortoise-front.jpg') %>",
        angle: "<%= image_path('frames/fitzgerald/tortoise-angle.jpg') %>",
        male: "<%= image_path('frames/fitzgerald/m.jpg') %>",
        female: "<%= image_path('frames/fitzgerald/f.jpg') %>"
      },
    },

    ford: {
      sub: 'inspired by Tom Ford.',
      desc: 'Strong curves and depth soften strong and angular features like prominent jaws and broader foreheads.',

      black: {
        side: "<%= image_path('frames/ford/black-side.jpg') %>",
        front: "<%= image_path('frames/ford/black-front.jpg') %>",
        angle: "<%= image_path('frames/ford/black-angle.jpg') %>",
        male: "<%= image_path('frames/ford/m.jpg') %>",
        female: "<%= image_path('frames/ford/f.jpg') %>"
      },

      tortoise: {
        side: "<%= image_path('frames/ford/tortoise-side.jpg') %>",
        front: "<%= image_path('frames/ford/tortoise-front.jpg') %>",
        angle: "<%= image_path('frames/ford/tortoise-angle.jpg') %>",
        male: "<%= image_path('frames/ford/m.jpg') %>",
        female: "<%= image_path('frames/ford/f.jpg') %>"
      },
    },

    monaco: {
      sub: 'inspired by Grace Kelly.',
      desc: 'A refined cat-eye frame which draws attention upwards towards the eyes and adds height to your cheekbones.',

      black: {
        side: "<%= image_path('frames/monaco/black-side.jpg') %>",
        front: "<%= image_path('frames/monaco/black-front.jpg') %>",
        angle: "<%= image_path('frames/monaco/black-angle.jpg') %>",
        male: "<%= image_path('frames/monaco/f.jpg') %>",
        female: "<%= image_path('frames/monaco/f.jpg') %>"
      },

      tortoise: {
        side: "<%= image_path('frames/monaco/tortoise-side.jpg') %>",
        front: "<%= image_path('frames/monaco/tortoise-front.jpg') %>",
        angle: "<%= image_path('frames/monaco/tortoise-angle.jpg') %>",
        male: "<%= image_path('frames/monaco/f.jpg') %>",
        female: "<%= image_path('frames/monaco/f.jpg') %>"
      },
    },

    stark: {
      sub: 'inspired by James Dean.',
      desc: 'A hybrid aviator, fusing depth and teardrop shapes to create a top-heavy effect and balance out fuller jaws.',

      black: {
        side: "<%= image_path('frames/stark/black-side.jpg') %>",
        front: "<%= image_path('frames/stark/black-front.jpg') %>",
        angle: "<%= image_path('frames/stark/black-angle.jpg') %>",
        male: "<%= image_path('frames/stark/m.jpg') %>",
        female: "<%= image_path('frames/stark/f.jpg') %>"
      },

      tortoise: {
        side: "<%= image_path('frames/stark/tortoise-side.jpg') %>",
        front: "<%= image_path('frames/stark/tortoise-front.jpg') %>",
        angle: "<%= image_path('frames/stark/tortoise-angle.jpg') %>",
        male: "<%= image_path('frames/stark/m.jpg') %>",
        female: "<%= image_path('frames/stark/f.jpg') %>"
      },
    },

    truman: {
      sub: 'inspired by Truman Capote.',
      desc: 'The combination of depth and angularity adds height to cheekbones and gives your face a longer, thinner profile.',

      black: {
        side: "<%= image_path('frames/truman/black-side.jpg') %>",
        front: "<%= image_path('frames/truman/black-front.jpg') %>",
        angle: "<%= image_path('frames/truman/black-angle.jpg') %>",
        male: "<%= image_path('frames/truman/m.jpg') %>",
        female: "<%= image_path('frames/truman/f.jpg') %>"
      },

      tortoise: {
        side: "<%= image_path('frames/truman/tortoise-side.jpg') %>",
        front: "<%= image_path('frames/truman/tortoise-front.jpg') %>",
        angle: "<%= image_path('frames/truman/tortoise-angle.jpg') %>",
        male: "<%= image_path('frames/truman/m.jpg') %>",
        female: "<%= image_path('frames/truman/f.jpg') %>"
      },
    },
  };

  function showFrame(name) {
    var panel = $('#panel');
    panel.attr('data-frame', name);
    panel.attr('data-image', 'angle');
    panel.find('div[data-image]').removeClass('selected');
    panel.find('div[data-image=angle]').addClass('selected');

    var frame = frames[name];
    panel.find('#frame aside > h1').text(name);
    panel.find('#frame aside > h2').text(frame.sub);
    panel.find('#frame aside .desc').text(frame.desc);

    // set the main frame image and the checkout image
    showImage();
    panel.show();
    $('#store-cover').show();

    // monaco doesn't have a male photo
    if (name == 'monaco')
      $('#frame div[data-image=male]').hide();
    else
      $('#frame div[data-image=male]').show();

    setTimeout(function() {
      $('#frames').addClass('blur');
      $('#store-cover').addClass('visible');
      panel.addClass('visible');
    }, 100);
  }

  function showImage() {
    var panel = $('#panel');
    var colour = panel.attr('data-colour');
    var image = panel.attr('data-image');
    var frame = panel.attr('data-frame');

    // set the main frame image
    var path = frames[frame][colour][image];
    panel.find('.photo').css('background-image', 'url(' + path + ')');

    // the checkout image is always angle
    var path = frames[frame][colour]['angle'];
    panel.find('#preview-photo').css('background-image', 'url(' + path + ')');

    // update the checkout form details text
    $('#preview-frame').text(frame);
    $('#preview-colour').text(colour);
  }

  $('#panel menu div[data-colour]').click(function(event) {
    var panel = $(this).closest('#panel');
    panel.attr('data-colour', $(this).attr('data-colour'));
    showImage(panel);

    panel.find('div[data-colour]').removeClass('selected');
    $(this).addClass('selected');
  });

  $('#panel menu div[data-image]').click(function(event) {
    var panel = $(this).closest('#panel');
    panel.attr('data-image', $(this).attr('data-image'));
    showImage(panel);

    panel.find('div[data-image]').removeClass('selected');
    $(this).addClass('selected');
  });

  $('#frames li').click(function(event) {
    showFrame($(this).attr('data-frame'));
  });

  function closePanel() {
    $('#panel').removeClass('visible');
    $('#store-cover').removeClass('visible');
    $('#frames').removeClass('blur');

    setTimeout(function() {
      $('#store-cover').hide();
      $('#panel').hide();
      $('#panel > div').hide();
      $('#frame').show();
    }, 1050);
  }

  $('#store-cover').click(function(event) {
    closePanel();
  });

  $('.close').click(function(event) {
    closePanel();
  })



  /* ----------------------------- */
  /* checkout                      */
  /* ----------------------------- */
  /* flow */
  $('#start-purchase').click(function(event) {
    event.preventDefault();
    $('#frame').fadeOut();
    $('#sizes').fadeIn();
  });

  $('#three-up a').click(function(event) {
    event.preventDefault();
    var size = $(this).attr('data-size');
    $(this).closest('#panel').attr('data-size', size);
    $('#preview-size').text(size);
    $('#sizes').fadeOut();
    $('#form').fadeIn();
  });

  $('#sizes .back').click(function(event) {
    $('#sizes').fadeOut();
    $('#frame').fadeIn();
  });

  $('#form .back').click(function(event) {
    $('#form').fadeOut();
    $('#sizes').fadeIn();
  });

  /* sizing measurement */
  function calcHighlight() {
    $('#three-up a').removeClass('selected');
    var size = $('#measurement-width').val();

    if ($('#inches').hasClass('selected'))
      size = size * 25.4;

    if (size <= 122) {
      $('#three-up a.small').addClass('selected');
    } else if (size <= 129) {
      $('#three-up a.medium').addClass('selected');
    } else {
      $('#three-up a.large').addClass('selected');
    }
  }

  $('#enter-measurement a').click(function(event) {
    $('#enter-measurement a').removeClass('selected');
    $(this).addClass('selected');
    calcHighlight();
    event.preventDefault();
  });

  $('#measurement-width').keyup(function(event) {
    calcHighlight();
  });

  /* stripe charges */

});