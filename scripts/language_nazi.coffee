# Description:
#   Helper script for the grammar nazis out there.
#

module.exports = (robot) ->

	# Estrangeirismos
	robot.hear	/applica(c|ç)(a|ã)o/i,			(msg) -> msg.send ":fpf: _aplicação_ :fpf:"
	robot.hear	/contracto/i, 				(msg) -> msg.send ":fpf: _contrato_ :fpf:"

	# Misc errors
	robot.hear	/copy(-|\s)past([^\w]|$)/i,				(msg) -> msg.send ":grammar: _copy-paste_ :grammar:"
	robot.hear	/([^\w]|^)([\w]*ç[ei][^\s]*)/i,				(msg) -> msg.send ":grammar: ~" + msg.match[2].trim() + "~ :grammar:"
	robot.hear	/([^\w]|^)([\w]*[áàéèíìóòúù][^\s]*mente([^\w]|$))/i,	(msg) -> msg.send ":grammar: ~" + msg.match[2].trim() + "~ :grammar:"
