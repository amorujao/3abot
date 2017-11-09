# Description:
#   Mining helper tools.
#
# Commands:
#   rig page - Returns the NiceHash URL for the default rig
#   rig page <rig name>
#   rig stats - Show current stats about the default rig
#   rig stats <rig name>
#   rig rates - Show the current BTC/EUR and BTC/USD exchanges rate
#   rig earnings - Show daily earnings for the default rig for the last 7 days
#   rig earnings( per <hour|day|week>)?( limit <count>)?( for <rig name>)?
#

ADDRESSES = {
  default: "1MBXSHNF9ttQ6a3sbJ9M98tyqEFgt8LmVm", portugal: "1MBXSHNF9ttQ6a3sbJ9M98tyqEFgt8LmVm",
  ricardo: "18uHwcnMzvHhtLqSbpGYvaQ9F9yskzhN32",
  holanda: "1GiBJ2hProdj9L4dHkfpKkMcVQ1K2b7b5G",
  maikk: "1Kw17Mk93gzHw3MPEorHPaoUqEJxKG5Y9o",
  fontela: "14MbxyGMdvSyTZnYz29gCA57TQWZPamaJf",
  alcobz: "1PX5DfRZmS1iy4z8eomeVLTm1wnGGQ3DaW",
  raspa: "1KzcpwsvPprriApyt2vKyXueero3AL1qzS",
  wise: "12PH87Hb8iD7YNWpz4MGVr5oE6GjsNsTtN", uaise: "12PH87Hb8iD7YNWpz4MGVr5oE6GjsNsTtN"
}

DEFAULT_RIG_HOST = "@alcobz"

NICEHASH_URL = "https://new.nicehash.com"
NICEHASH_API_URL = "https://api.nicehash.com/api"
BTC_QUOTES_URL = "http://api.coindesk.com/v1/bpi/currentprice/EUR.json"

round = (value, precision) ->
  multiplier = Math.pow(10, precision || 0)
  Math.round(value * multiplier) / multiplier

minerPage = (address) ->
  NICEHASH_URL + "/miner/" + address

addressByName = (name) ->
  if ADDRESSES[name.toLowerCase()]
    ADDRESSES[name.toLowerCase()]
  else
    false

secondsToString = (seconds) ->
  years = Math.floor(seconds / 31536000)
  days = Math.floor((seconds % 31536000) / 86400)
  hours = Math.floor(((seconds % 31536000) % 86400) / 3600)
  minutes = Math.floor((((seconds % 31536000) % 86400) % 3600) / 60)
  seconds = Math.floor((((seconds % 31536000) % 86400) % 3600) % 60)
  parts = []
  if years
    s = years + " year"
    if years > 1
      s += "s"
    parts.push s
  if days
    s = days + " day"
    if days > 1
      s += "s"
    parts.push s
  if hours
    s = hours + " hour"
    if hours > 1
      hours += "s"
    parts.push s
  if minutes
    s = minutes + " minute"
    if minutes > 1
      s += "s"
    parts.push s
  if seconds
    s = seconds + " seconds"
    if seconds > 1
      s += "s"
    parts.push s
  parts.join(' ')

readableTimeToSeconds = (str) ->
  if str == "hour"
    60*60
  else if str == "day"
    24*60*60
  else if str == "week"
    7*24*60*60
  else
    -1

timestampToString = (timestamp) ->
  new Date(timestamp * 1000).toISOString().substr 0, 19

class Rig

	constructor: (@robot) ->

	status: (msg, address, warnUserIfOffline) ->
    msg.http(NICEHASH_API_URL)
      .query(
        method: 'stats.provider.ex',
        addr: address
      ).get() (err, res, body) ->

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
            paid_balance += (Number) payment.amount
          if algos.length > 0
            msg.send "Mining: " + algos.join(' + ')
          else
            msg.send ":fire::fire::fire: " + warnUserIfOffline + " *RIG OFFLINE* :fire::fire::fire:"

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
                  text += "*Recently Paid*: " + round(paid_balance * 1000000) + " μBTC ≈ *" + paid_eur + " €*\n"
                text += "_1 BTC ≈ " + round(eurbtc, 2) + " €_"
                msg.send text
                #msg.send "Source: " + NICEHASH_API_URL + "?method=stats.provider.ex&addr=" + address

	history: (msg, address, from, group_size) ->

    #interval_str = secondsToString group_size
    #since_str = secondsToString (Date.now() / 1000 - from)
    #msg.send "Earnings for each period of " + interval_str + " in the last " + since_str + " (from oldest to newest):"
    msg.http(NICEHASH_API_URL)
      .query(
        method: 'stats.provider.ex',
        addr: address,
        from: from
      ).get() (err, res, body) ->

        if err
          msg.send "Nicehash API request failed :cry:"
          return
        miner = JSON.parse body
        if !miner.result.past
          if miner.result.error
            msg.send miner.result.error
          else
            msg.send "Unexpected response from Nicehash API: \n" + body
          return
        t0 = 0
        for algo in miner.result.past
          if algo.data && algo.data.length > 0 && (t0 == 0 || t0 > (300 * algo.data[0][0]))
            t0 = 300 * algo.data[0][0]
        balances = []# balance in satoshis
        timestamps = []
        for algo in miner.result.past
          next_ts = 0
          j = 0
          remaining_balance = 0
          for data in algo.data
            ts = 300 * data[0]
            remaining_balance = Math.round(100000000 * data[2])
            if ts >= next_ts
              if !balances[j]
                balances[j] = 0
              balances[j] = balances[j] + remaining_balance
              timestamps[j] = ts
              next_ts = ts + group_size
              j++
              remaining_balance = 0
          if remaining_balance
            if !balances[j]
              balances[j] = 0
            balances[j] = balances[j] + remaining_balance
            timestamps[j] = ts

        now = Math.floor(Date.now() / 1000)
        earnings = []
        for i in [0..balances.length-2]
          end_ts = timestamps[i] + group_size
          if end_ts > now
            end_ts = now
          earnings[i] = timestampToString(timestamps[i]) + "-" + timestampToString(end_ts) + " (UTC): *" + Math.round((balances[i+1] - balances[i]) / 100) + " μBTC*"
        msg.send earnings.join("\n")

  earnings: (msg, interval_str, count, rig) ->
    interval = readableTimeToSeconds interval_str
    if interval <= 0
      msg.send "Unsupported time interval: '" + interval_str + "'"
      return
    address = ADDRESSES.default
    rigname = ""
    hours = msg.match[1]
    if rig.length > 0
      address = addressByName rig
      if !address
        address = rig
        rigname = " for " + address
      else
        rigname = " for " + rig + "'s rig"
    msg.send "Loading earnings per " + interval_str + " in the last " + count + " " + interval_str + "s" + rigname + "..."
    @history(msg, address, Math.floor(Date.now()/1000 - count * interval), interval)

module.exports = (robot) ->

	rig = new Rig(robot)

	robot.hear /rig statu?s( \w+)?\.?$/i, (msg) ->
    address = ADDRESSES.default
    warnUserIfOffline = DEFAULT_RIG_HOST
    if msg.match.length > 1 && msg.match[1]
      name = msg.match[1].substr 1
      address = addressByName name
      if !address
        address = name
        warnUserIfOffline = ""
        msg.send "Loading stats for " + address + "..."
      else
        warnUserIfOffline = name + "-rig-offline"
        msg.send "Loading stats for " + name + "'s rig..."
    rig.status(msg, address, warnUserIfOffline)

	robot.hear /rig (page|url)( \w+)?$/i, (msg) ->
    address = ADDRESSES.default
    if msg.match.length > 2 && msg.match[2]
      name = msg.match[2].substr 1
      address = addressByName name
      if !address
        msg.send "Unknown rig: _" + name + "_"
        return
    msg.send minerPage address

	robot.hear /rig earnings per hour\.?$/i, (msg)                        -> rig.earnings(msg, "hour",      24,            "")
	robot.hear /rig earnings per hour for (\w+)\.?$/i, (msg)              -> rig.earnings(msg, "hour",      24,            msg.match[1])
	robot.hear /rig earnings( per day)?\.?$/i, (msg)                      -> rig.earnings(msg, "day",        7,            "")
	robot.hear /rig earnings per day for (\w+)?\.?$/i, (msg)              -> rig.earnings(msg, "day",        7,            msg.match[1])
	robot.hear /rig earnings per week\.?$/i, (msg)                        -> rig.earnings(msg, "week",       4,            "")
	robot.hear /rig earnings per week for (\w+)\.?$/i, (msg)              -> rig.earnings(msg, "week",       4,            msg.match[1])
	robot.hear /rig earnings for (\w+)\.?$/i, (msg)                       -> rig.earnings(msg, "day",        7,            msg.match[1])
	robot.hear /rig earnings per (\w+) limit (\d+)\.?$/i, (msg)           -> rig.earnings(msg, msg.match[1], msg.match[2], "")
	robot.hear /rig earnings per (\w+) limit (\d+) for (\w+)\.?$/i, (msg) -> rig.earnings(msg, msg.match[1], msg.match[2], msg.match[3])

	robot.hear /rig rates?/i, (msg) ->
    if msg.message.user.room != "mining-status" && msg.message.user.room != "hubot" && msg.message.user.room != "Shell"
      msg.send "Please run this on #mining-status instead"
      return
    msg.http(BTC_QUOTES_URL)
      .get() (err, res, body) ->
        if err
          msg.send "Failed to fetch Bitcoin quotes :cry:"
        else
          quotes = JSON.parse body
          btceur = quotes.bpi.EUR.rate_float
          btcusd = quotes.bpi.USD.rate_float
          msg.send "1 BTC ≈ " + round(btceur, 2) + " EUR ≈ " + round(btcusd, 2) + " USD"
