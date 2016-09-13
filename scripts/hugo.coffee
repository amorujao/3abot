# Description:
#   Hugo responses (he deserves it!)
#

module.exports = (robot) ->

	responses = [
		"tretas",
		"tretas!",
		"q treta",
		"lixo",
		"não inventes hugo",
		"só inventas hugo"
	]

	robot.hear /.+/, (msg) ->
		if msg.message.user.name == 'hugo' && msg.message.text.search(/(yo+|ola|boas)/i) < 0 && Math.random() < 0.1
			msg.send msg.random responses
