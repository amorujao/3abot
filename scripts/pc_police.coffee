module.exports = (robot) ->

	robot.hear /(branco|preto|black|white|cigan|indian|jew)/, (msg) ->
		if Math.random() < 0.1
			msg.send 'racista'

	robot.hear /(gaja)/, (msg) ->
		if Math.random() < 0.2
			msg.send 'sexista'
