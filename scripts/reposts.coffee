# Description:
#   Stores recently posted links and flags reposts.
#
# Inspired by: https://github.com/ClaudeBot/hubot-links/blob/master/src/hubot-links.coffee
#

class RepostTracker

	LINKS_KEY = "reposts.links"
	REPOSTERS_KEY = "reposts.reposters"
	MAX_LINKS = 10000
	REPOST_MSGS = [
		# shame nun static images
		"https://pbs.twimg.com/media/CVkAep3UkAAXUXT.jpg",
		# shame nun gifs
		"http://i.imgur.com/FidZknJ.gif",
		"https://m.popkey.co/6bee24/6GJWk.gif",
		"https://m.popkey.co/f6d204/LWYby_s-200x150.gif",
		"https://media.tenor.co/images/a0c47819d0ff3547b6f9e943aecdc3ec/raw"
	]

	constructor: (@robot) ->
		@clear()
		@robot.brain.on 'loaded', (data) =>
			if ! @links()
				@clear()

	clear: ->
		@robot.brain.set(LINKS_KEY, [])
		@robot.brain.set(REPOSTERS_KEY, {})

	links: ->
		@robot.brain.get(LINKS_KEY)

	reposters: ->
		@robot.brain.get(REPOSTERS_KEY)

	add: (link) ->
		l = @links()
		l.push link
		if l.length > MAX_LINKS
			l.splice(0, l.length - MAX_LINKS)

	track: (msg, url) ->
		for link in @links()
			if url is link[0]
				dateObj = new Date(link[3])
				dateStr = "#{dateObj.getFullYear()}-#{dateObj.getMonth()+1}-#{dateObj.getDate()} @ #{dateObj.getHours()}:#{dateObj.getMinutes()}"
				msg.send "repost"
				msg.send link[1] + " posted this on " + dateStr
				msg.send msg.random REPOST_MSGS
				reposters = @reposters()
				reposters[msg.message.user.name] = (reposters[msg.message.user.name] or 0) + 1
				return

		@add([url, msg.message.user.name, msg.message.user.room, new Date()])

module.exports = (robot) ->

	tracker = new RepostTracker(robot)

	IGNORE_USERS = [
		robot.name,
		"slackbot",
		"RightGIF",
		"github"
	]

	IGNORE_URLS_PREFIX = [
		"giphy.com/gifs/",
		"amazon.", "www.amazon.",
		"nicehash.", "www.nicehash.", "new.nicehash.", "api.nicehash.",
		"pcpartpicker.",
		"globaldata.pt",
		"hangouts.google.com"
		"twitch.tv", "www.twitch.tv",
		"gamesdonequick.com"
	]

	robot.respond /clear repost data/i, (msg) ->

		if not msg.message.user.is_owner
			msg.send "Access denied."
			return

		linkCount = tracker.links().length
		if linkCount > 0
			tracker.clear()
			msg.send "Deleted " + linkCount + " link(s) and reset repost counters."
		else
			msg.send "There were no links to delete."

	robot.respond /count repost links/i, (msg) ->
		msg.send "So far, I've tracked " + tracker.links().length + " link(s)."

	robot.respond /count reposts/i, (msg) ->

		reposters = tracker.reposters()
		count = 0
		for name, c of reposters
			count += c
		msg.send "Tracked " + count + " repost(s)."
		if count > 0
			msg.send "You're welcome."

	robot.respond /list repost links/i, (msg) ->

		if not msg.message.user.is_owner
			msg.send "Access denied."
			return

		links = tracker.links()
		if links.length is 0
			msg.send "No links have been tracked so far."
		else
			msg.send "Links tracked:"
			for link, i in links
				msg.send (i + 1) + ": " + link[0]

	robot.respond /list reposters/i, (msg) ->

		reposters = tracker.reposters()
		if Object.keys(reposters).length is 0
			msg.send "No reposts have been tracked so far."
		else
			msg.send "Reposts tracked:"
			for name, count of reposters
				msg.send name + ": " + count

	robot.hear /(https?:\/\/)([^\s\/$.?#].[^\/\s#]+\/[^\s#]+)(#[^\s]*)?(\s|$)/i, (msg) ->

		if ! msg.message.user.name or msg.message.user.name in IGNORE_USERS 
			return

		url = msg.match[2]

		for prefix in IGNORE_URLS_PREFIX
			if url.slice(0, prefix.length) is prefix
				return

		# assume that posts with newlines are "Shares", which shouldn't count as reposts
		if msg.message.text.search("\n") >= 0
			return

		tracker.track(msg, url)
