# Description:
#   HAL9000 responses (simple sample script)
#

getUser = (msg) ->
	if msg.message.user.real_name != undefined then msg.message.user.real_name else msg.message.user.name

getFirstName = (msg) ->
	if msg.message.user.real_name != undefined
		names = msg.message.user.real_name.split(" ")
		names[0]
	else
		msg.message.user.name

module.exports = (robot) ->

	bot = '('+robot.name+'|'+robot.alias+')';

	robot.hear /open the (.*) doors/i, (msg) ->
		doorType = msg.match[1]
		if doorType is "pod bay"
			msg.send "I'm sorry, " + getFirstName(msg) + ". I'm afraid I can't do that."
		else
			msg.send "Opening #{doorType} doors"

	robot.hear new RegExp("good morning " + bot, "i"), (msg) ->
		msg.send "Good morning, " + getFirstName(msg) + "."
