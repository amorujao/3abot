# Description:
#   Helper script for the grammar nazis out there.
#

module.exports = (robot) ->

	# Estrangeirismos
	robot.hear	/applica(c|ç)(a|ã)o/i,		(msg) -> msg.send ":fpf: _aplicação_"
	robot.hear	/contracto/i, 			(msg) -> msg.send ":fpf: _contrato_"

	# Misc errors
	robot.hear	/copy(-|\s)past([^e]|$)/i,	(msg) -> msg.send ":grammar: _copy-paste_"
