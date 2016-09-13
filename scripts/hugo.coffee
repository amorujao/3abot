# Description:
#   HAL9000 responses (simple sample script)
#

module.exports = (robot) ->

	responses = [
		"tretas",
		"tretas!",
		"q treta",
		"lixo",
		"não inventes hugo",
		"não acreditem no q ele diz"
	]

	robot.hear /.+/, (msg) ->
		if msg.message.user.name == 'hugo' && msg.message.text.search(/(yo+|ola|boas)/i) < 0 && Math.random() < 0.05
			msg.send msg.random responses
