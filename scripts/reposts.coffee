# Description:
#   Stores recently posted links and flags reposts.
#
# Inspired by: https://github.com/ClaudeBot/hubot-links/blob/master/src/hubot-links.coffee
#

module.exports = (robot) ->

	DATA_KEY = "links"
	MAX_LINKS = 5000

	_links = robot.brain.data[DATA_KEY]
	_links ?= []

	robot.respond /list links/i, (msg) ->
		msg.send "Links tracked so far, from oldest to latest:"
		for link in _links
			msg.send link[0]

	robot.hear /(https?:\/\/|www\.)[^\s\/$.?#].[^\s]+\/[^\s]+/i, (msg) ->
		urlParts = msg.match[0].split("#")
		url = urlParts[0]

		match = null
		saveData = true
		for link, i in _links
			if url is link[0]
				match = link
				saveData = false
				break
			# partial match; update data with the smallest version
			if url.indexOf(link[0]) isnt -1 or link[0].indexOf(url) isnt -1
				if link[0].length > url.length
					link[0] = url
					_links[i] = link
				else
					saveData = false
				match = link
				break

		if match isnt null
			dateObj = match[3]
			dateStr = "#{dateObj.getFullYear()}-#{dateObj.getMonth()}-#{dateObj.getDate()} @ #{dateObj.getHours()}:#{dateObj.getMinutes()}"
			msg.send "repost (posted by " + match[1] + " on " + dateStr + ")"
		else
			_links.push [url, msg.message.user.name, msg.message.user.room, new Date()]

		if _links.length > MAX_LINKS
			_links.splice(0, _links.length - MAX_LINKS)
			saveData = true

		if saveData
			robot.brain.data[DATA_KEY] = _links
