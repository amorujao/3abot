# Description:
#   Mining helper tools.
#

ADDRESSES = {
  default: "1MBXSHNF9ttQ6a3sbJ9M98tyqEFgt8LmVm",
  ricardo: "1FmV8YK553H2KX7ArZDMCWo2uaW2ZCFCKt",
  holanda: "1GiBJ2hProdj9L4dHkfpKkMcVQ1K2b7b5G",
  maikk: "1Kw17Mk93gzHw3MPEorHPaoUqEJxKG5Y9o",
  fontela: "14MbxyGMdvSyTZnYz29gCA57TQWZPamaJf",
  alcobz: "1PX5DfRZmS1iy4z8eomeVLTm1wnGGQ3DaW",
  raspa: "1KzcpwsvPprriApyt2vKyXueero3AL1qzS",
  wise: "12PH87Hb8iD7YNWpz4MGVr5oE6GjsNsTtN", uaise: "12PH87Hb8iD7YNWpz4MGVr5oE6GjsNsTtN"
}

NICEHASH_URL = "https://new.nicehash.com"
NICEHASH_API_URL = "https://api.nicehash.com/api"
BTC_QUOTES_URL = "http://api.coindesk.com/v1/bpi/currentprice/EUR.json"
HOUSE_ON_FIRE_MSGS = [
  ":fearful:",
  ":fire::fire::fire::fire::fire::fire::fire::fire::fire:",
  "Não façam perguntas para as quais não querem ouvir a resposta :|",
  "Erm... :fearful: command not found, please try again",
  "https://media.giphy.com/media/3o6ZtjsJwjOsIfOZd6/giphy.gif"
]

round = (value, precision) ->
  multiplier = Math.pow(10, precision || 0)
  Math.round(value * multiplier) / multiplier

minerPage = (address) ->
  NICEHASH_URL + "/miner/" + address

addressByName = (name) ->
  if ADDRESSES[name]
    ADDRESSES[name]
  else
    false

class Rig

	constructor: (@robot) ->

	status: (msg, address) ->
    msg.http(NICEHASH_API_URL)
      .query(
        method: 'stats.provider.ex',
        addr: address,
        from: Math.floor(Date.now() / 1000))
      .get() (err, res, body) ->

        if err
          msg.send "Nicehash API request failed :cry: please use the miner page instead:"
          msg.send minerPage address
        else
          miner = JSON.parse body
          current = JSON.stringify miner.result.current
          if !miner.result.current
            if miner.result.error
              msg.send miner.result.error
            else
              msg.send "Unexpected response from Nicehash API: \n" + body
            return
          profitability = 0
          unpaid_balance = 0
          paid_balance = 0
          algos = []
          for algo in miner.result.current
            if Object.keys(algo.data[0]).length > 0
              if algo.data[0].a != undefined
                algos.push algo.name + " @ " + algo.data[0].a + " " + algo.suffix + "/s"
                profitability += (Number) algo.data[0].a * (Number) algo.profitability
            unpaid_balance += (Number) algo.data[1]
          for payment in miner.result.payments
            paid_balance += payment.amount
          if algos.length > 0
            msg.send "Mining: " + algos.join(' + ')
          else
            msg.send ":fire::fire::fire: *RIG OFFLINE* :fire::fire::fire:"

          msg.http(BTC_QUOTES_URL)
            .get() (err2, res2, body2) ->
              if err2
                msg.send "Failed to fetch BTCEUR quote :cry: please use the miner page instead:\n" + minerPage address
              else
                quotes = JSON.parse body2
                eurbtc = quotes.bpi.EUR.rate_float

                profit_eur = round(profitability * eurbtc, 2)
                unpaid_eur = round(unpaid_balance * eurbtc, 2)
                paid_eur   = round(paid_balance * eurbtc, 2)

                text = ""
                if algos.length > 0
                  text += "*Earnings/day*: " + round(profitability * 1000000) + " μBTC ≈ *" + profit_eur + " €*\n"
                text += "*Unpaid*: " + round(unpaid_balance * 1000000) + " μBTC ≈ *" + unpaid_eur + " €*\n"
                if paid_balance > 0
                  text += "*Paid*: " + round(paid_balance * 1000000) + " μBTC ≈ *" + paid_eur + " €*\n"
                text += "_1 BTC ≈ " + round(eurbtc, 2) + " €_"
                msg.send text
                #msg.send "Source: " + NICEHASH_API_URL + "?method=stats.provider.ex&addr=" + address

module.exports = (robot) ->

	rig = new Rig(robot)

	robot.hear /rig statu?s( \w+)?/i, (msg) ->
    address = ADDRESSES.default
    if msg.match.length > 1 && msg.match[1]
      name = msg.match[1].substr 1
      address = addressByName name
      if !address
        address = name
        msg.send "Loading stats for " + address + "..."
      else
        msg.send "Loading stats for " + name + "'s rig..."
    rig.status(msg, address)

	robot.hear /rig (page|url)( \w+)?/i, (msg) ->
    address = ADDRESSES.default
    if msg.match.length > 2 && msg.match[2]
      name = msg.match[2].substr 1
      address = addressByName name
      if !address
        msg.send "Unknown rig: _" + name + "_"
        return
    msg.send minerPage address

	robot.hear /rig rates?/i, (msg) ->
    msg.http(BTC_QUOTES_URL)
      .get() (err, res, body) ->
        if err
          msg.send "Failed to fetch Bitcoin quotes :cry:"
        else
          quotes = JSON.parse body
          btceur = quotes.bpi.EUR.rate_float
          btcusd = quotes.bpi.USD.rate_float
          msg.send "1 BTC ≈ " + round(btceur, 2) + " EUR ≈ " + round(btcusd, 2) + " USD"

  robot.hear /a casa do raspa já ardeu\?/i, (msg) ->
    msg.send "Checking..."
    msg.http(NICEHASH_API_URL)
      .query(
        method: 'stats.provider.ex',
        addr: ADDRESSES.default)
      .get() (err, res, body) ->

        if err
          msg.send "Nicehash API request failed :cry: please use the miner page instead:"
          msg.send minerPage ADDRESSES.default
        else
          miner = JSON.parse body
          current = JSON.stringify miner.result.current
          for algo in miner.result.current
            if Object.keys(algo.data[0]).length > 0
              msg.send "Ainda não!"
              return

        msg.send msg.random HOUSE_ON_FIRE_MSGS
