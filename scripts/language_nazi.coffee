# Description:
#   Helper script for the grammar nazis out there.
#

module.exports = (robot) ->

	INSULTS = [
		"You donkey-raping shit-eater",
		"I hate rainbows...I hate the way they come into your house, crawl up your leg and start biting the inside of your ass.",
		"You're such a pig fucker",
		"You shit-faced cock-master",
		"Shut up, you'll never be the man your mother is.",
		"You're a failed abortion whose birth certificate is an apology from the condom factory.",
		"You must have been born on a highway, because that's where most accidents happen.",
		"Your family tree is a cactus, because everybody on it is a prick.",
		"You're so ugly Hello Kitty said goodbye to you.",
		"It looks like your face caught on fire and someone tried to put it out with a fork.",
		"You are so ugly that when your mama dropped you off at school she got a fine for littering.",
		"If you were twice as smart, you'd still be stupid.",
		"You're so ugly when you popped out the doctor said aww what a treasure and your mom said yeah lets bury it",
		"You are the reason people are blind",
		"Dumbass.",
		"We all sprang from apes, but you didn't spring far enough.",
		"I hear when you were a child your mother wanted to hire somebody to take care of you, but the mafia wanted too much.",
		"Out of 100,000 sperm, you were the fastest?",
		"I would ask how old you are, but I know you can't count that high.",
		"If you really want to know about mistakes, you should ask your parents.",
		"I could eat a bowl of alphabet soup and crap out a smarter comeback than what you just said.",
		"Your mamma so fat she has to wear 2 watches because she covers two time zones.",
		"Is your ass jealous of the amount of shit that just came out of your mouth?",
		"I'm not saying I hate you, but I would unplug your life support to charge my phone.",
		"Roses are red, violets are blue, I have 5 fingers, the 3rd ones for you.",
		"I wasn't born with enough middle fingers to let you know how I feel about you.",
		"I bet your brain feels as good as new, seeing that you never use it.",
		"I'm jealous of all the people that haven't met you!","You bring everyone a lot of joy, when you leave the room.",
		"I'd like to see things from your point of view but I can't seem to get my head that far up my ass.",
		"If I wanted to kill myself I'd climb your ego and jump to your IQ.",
		"I don't exactly hate you, but if you were on fire and I had water, I'd drink it.",
		"It's better to let someone think you are an Idiot than to open your mouth and prove it.",
		"I have neither the time nor the crayons to explain this to you.","What are you going to do for a face when the baboon wants his butt back?",
		"If I were to slap you, it would be considered animal abuse!",
		"YOU DIRTY ROTTEN LOWDOWN SLIMY FILTHY DISGUSTING GLUTTONOUS HOGLIKE MOTHER FUCKING COCK SUCKING SON OF AN INCESTUOUS PEDOPHILE SHEMALE RAPIST PROSTITUTE.",
		"I'M GONNA SHIT UP YOUR ASS. STOP FOR A MOMENT AND REALLY GRASP THAT STATEMENT. I AM LITERALLY GOING TO SHIT UP YOUR ASS. I WILL TAKE MY PANTS OFF, RIP YOUR PANTS OFF, OUR SPHINCTERS WILL TOUCH, AND I WILL SHIT. YOU WILL TRY TO COUNTERSHIT, BUT MY SPHINCTER WILL OVERCOME, AND I WILL PUSH A LOG OF SHIT FROM MY ASS UP AND INTO YOUR BODY.",
		"Everyday I see you it makes me happy, because I know you are one day closer to being dead.",
		"Well it looks to me like the best part of you ran down the crack of your momma's ass and ended up as a brown stain on the mattress!",
		"I BET YOU'RE THE KIND OF GUY WHO'D FUCK A MAN IN THE ASS AND NOT HAVE THE COMMON COURTESY TO GIVE HIM A REACH-AROUND.",
		"You're an inspiration for birth control.",
		"I bet the sperm bank accepts your spit as donations.",
		"You fucking niggercunt.",
		"You are a poopy pants."
	]

	# Estrangeirismos
	# robot.hear	/applica(c|ç)(a|ã)o/i,			(msg) -> msg.send ":fpf: _aplicação_ :fpf: " + msg.random INSULTS
	# robot.hear	/contracto/i, 				(msg) -> msg.send ":fpf: _contrato_ :fpf: " + msg.random INSULTS
	# robot.hear	/producto/i,				(msg) -> msg.send ":fpf: _produto_ :fpf: " + msg.random INSULTS

	# Misc errors
	# robot.hear	/copy(-|\s)past([^\w]|$)/i,				(msg) -> msg.send ":grammar: _copy-paste_ :grammar: " + msg.random INSULTS
	# robot.hear	/([^\w]|^)([\w]*ç[ei][^\s]*)/i,				(msg) -> msg.send ":grammar: ~" + msg.match[2].trim() + "~ :grammar: " + msg.random INSULTS
	# robot.hear	/([^\w]|^)([\w]*[áàéèíìóòúù][^\s]*mente([^\w]|$))/i,	(msg) -> msg.send ":grammar: ~" + msg.match[2].trim() + "~ :grammar: " + msg.random INSULTS
  robot.hear	/(c|k)usta(-|\s)me a querer/i,				(msg) -> msg.send "a querer ou a crer?"
