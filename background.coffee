chrome.runtime.onMessage.addListener (req, sender, sendResponse) ->
  if req["init_script"]
    chrome.browserAction.setBadgeText text: ''
  else if req["has_leap"] && req["has_leap"] == true
    chrome.browserAction.setBadgeBackgroundColor  color: [0, 255, 0, 255]
    chrome.browserAction.setBadgeText text: 'ON'
  else if req["has_leap"] && req["has_leap"] == false
    chrome.browserAction.setBadgeText text: 'OFF'
    chrome.browserAction.setBadgeBackgroundColor  color: [255, 0, 0, 255]