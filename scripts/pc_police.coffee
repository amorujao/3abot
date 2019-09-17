module.exports = (robot) ->

	robot.hear /(branco|preto|black|white|cigan|indian|jew)/, (msg) ->
		if Math.random() < 0.1
			msg.send 'racista'
