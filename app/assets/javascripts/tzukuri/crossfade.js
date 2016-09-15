/**
 * event triggers
 * ----------------------
 * [tzukuri.crossfade.stop] - the crossfader on this element has been manually stopped
 * [tzukuri.crossfade.start] - the crossfader on this element has been manually started
 * [tzukuri.crossfade.fadeStart] - the crossfader has started animating from one image to another
 * [tzukuri.crossfade.fadeStop] - the crossfader has finished animating from one image to another
 */

var crossfade = (function (el, childEl) {
  var c = {}

  c.element = $(el)
  c.children = c.element.find(childEl)

  // hide all the images but the first one
  c.children.hide()
  $(c.children[0]).show()

  // todo: pass these in as optional arguments
  var FADE_WAIT =  6500
  var FADEOUT_TIME = 1000
  var FADEIN_TIME =  1500

  var states = {
    RUNNING: 0,
    STOPPED: 1
  }

  var _animating = false
  var _state = states.STOPPED
  var _current = 0
  var _timer = undefined

  // -------------------
  // public functions
  // -------------------

  /**
   * [start start the crossfader fading images in the order they appear in markup]
   */
  c.start = function() {
    c.element.trigger('tzukuri.crossfade.start')
    _state = states.RUNNING
    _beginFade()
  }

  /**
   * [stop stop the crossfader fading images, stopping on the current image unless a fade is in process, then it will wait for the current fade to complete]
   */
  c.stop = function() {
    clearTimeout(_timer)
    _state = states.STOPPED
    c.element.trigger('tzukuri.crossfade.stop')
  }

  /**
   * [next manually show the next image, stops the crossfader if currently running]
   */
  c.next = function() {
    if (_state == states.RUNNING) c.stop()
    if (!_animating) _fadeBetween('forward')
  }

  /**
   * [previous manually show the previous image, stops the crossfader if currently running]
   */
  c.previous = function() {
    if (_state == states.RUNNING) c.stop()
    if (!_animating) _fadeBetween('back')
  }

  // -------------------
  // private functions
  // -------------------
  var _fadeBetween = function(direction) {
    var next = direction == 'forward' ? _nextIndex() : _prevIndex()
    _animating = true
    c.element.trigger('tzukuri.crossfade.fadeStart', [_current, next])

    $(_currentImage()).fadeOut(FADEOUT_TIME, function() {
        $(c.children[next]).fadeIn(FADEIN_TIME, function() {
            _current = next
            _animating = false
            c.element.trigger('tzukuri.crossfade.fadeEnd', [_current])

            // only continue automatically if the state isn't stopped
            if (_state == states.RUNNING) _beginFade()
        })
    })
  }

  var _beginFade = function() {
    _timer = setTimeout(function() {
        _fadeBetween('forward')
    }, FADE_WAIT)
  }

  var _currentImage = function() {
    return c.children[_current]
  }

  var _nextIndex = function() {
    return (_current + 1) >= c.children.length ? 0 : _current + 1
  }

  var _prevIndex = function() {
    return _current <= 0 ? c.children.length - 1 : _current - 1
  }

  return c;
});
