module.exports = (robot) ->

	robot.hear /(branco|branca|preto|preta|black|white|cigan|indian|jew|judeu|judia)/, (msg) ->
		if Math.random() < 0.08
			msg.send 'racista'

	robot.hear /(gaja)/, (msg) ->
		if Math.random() < 0.2
			msg.send 'sexista'
