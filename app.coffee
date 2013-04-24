_translationFactor = 20
_smoothingFactor = 4
_debug = false
_animationsPaused = false
_defaultAnimationPauseMs = 200
_sentMessage = false

#Add debug pane of info
if _debug
  debugPane = document.createElement 'div'
  debugPane.style.backgroundColor = 'rgba(255,255,255,0.7)'
  debugPane.style.bottom = '10px'
  debugPane.style.left = '10px'
  debugPane.style.position = 'fixed'
  document.body.appendChild debugPane

  gesturePane = document.createElement 'div'
  gesturePane.style.backgroundColor = 'rgba(255,255,255,0.7)'
  gesturePane.style.top = '10px'
  gesturePane.style.left = '10px'
  gesturePane.style.position = 'fixed'
  document.body.appendChild gesturePane

chrome.runtime.sendMessage init_script: true

Leap.loop enableGestures: true, (frame) ->
  if !_sentMessage
    chrome.runtime.sendMessage has_leap: true
    _sentMessage = true

  if _debug
    debugPane.innerHTML = frame.dump()

  fingers = frame.fingers
  hands = frame.hands

  # Don't do anything if there's nothing in the frame
  return if fingers.length == 0

  # Check for gestures
  if frame.gestures.length > 0
    firstGesture = frame.gestures[0]

    # console.log JSON.stringify(firstGesture)
    if _debug
      gesturePane.innerHTML = '<div>' + _animationsPaused + JSON.stringify(firstGesture) + '</div>' + gesturePane.innerHTML

    return if _animationsPaused

    speed = firstGesture.speed || 0
    if firstGesture.direction
      direction = 
        x: firstGesture.direction[0]
        z: firstGesture.direction[1]
        y: firstGesture.direction[2]
    state = firstGesture.state || ''
    type = firstGesture.type
    duration = (firstGesture.duration || 0) / 60000

    #Quick scroll down
    if type == 'keyTap' && fingers.length < 3 #limit number of fingers so we don't have accidental keytaps
      quickScroll 'down'

    #Quick scroll up
    else if type == 'swipe' && state == 'stop'
      verticalDistance = firstGesture.position[1] - firstGesture.startPosition[1]

      # console.log 
      #   dist: parseInt(verticalDistance)
      #   dur: parseInt(duration * 10) / 10
      #   speed: parseInt(firstGesture.speed)

      if verticalDistance > 100 && speed > 100 && fingers.length > 2
        if hands.length == 2
          scrollToTop()
        else
          quickScroll 'up'

scrollToTop = () ->
  # smoothScroll -document.height
  window.scrollBy -document.height
  pauseAnimations()

quickScroll = (dir, pause = _defaultAnimationPauseMs) ->
  factor = if dir == 'up' then -1 else 1
  # smoothScroll (window.innerHeight - 120) * factor
  window.scrollBy 0, (window.innerHeight - 120) * factor
  pauseAnimations(pause)

pauseAnimations = (pause = _defaultAnimationPauseMs) ->
  _animationsPaused = true
  setTimeout (() => _animationsPaused = false), pause

# smoothScroll = (amt) ->
#   startY = window.scrollY
#   stopY = Math.min(Math.max(startY + amt, 0), document.height)
#   dist = Math.abs stopY - startY
#   speed = Math.max(Math.round(dist / 100), 30)
#   step = Math.round(dist / 25)
#   timer = 0

#   if dist < 100
#     return window.scrollTo 0, stopY

#   #scrolling down
#   leapY = startY + step
#   if amt > 0
#     while leapY < stopY
#       setTimeout 'window.scrollTo(0, ' + leapY + ')', timer * speed
#       leapY += step
#       leapY = stopY if leapY > stopY
#       timer += 1
#   #scrolling up
#   else
#     while leapY > stopY
#       setTimeout 'window.scrollTo(0, ' + leapY + ')', timer * speed
#       leapY -= step
#       leapY = stopY if leapY < stopY
#       timer += 1