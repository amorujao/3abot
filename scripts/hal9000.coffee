# Description:
#   HAL9000 responses (simple sample script)
#

getUser = (msg) ->
	if msg.message.user.real_name != undefined then msg.message.user.real_name else msg.message.user.name

module.exports = (robot) ->

	bot = '('+robot.name+'|'+robot.alias+')';

	robot.respond /open the (.*) doors/i, (res) ->
		doorType = res.match[1]
		if doorType is "pod bay"
			res.reply "I'm sorry, " + getUser(res) + ". I'm afraid I can't do that."
		else
			res.reply "Opening #{doorType} doors"

	robot.hear new RegExp("good morning " + bot, "i"), (res) ->
		res.reply "Good morning, " + getUser(res) + "."
