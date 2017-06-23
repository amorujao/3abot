# Description:
#   Mining helper tools.
#

round = (value, precision) ->
  multiplier = Math.pow(10, precision || 0)
  Math.round(value * multiplier) / multiplier

module.exports = (robot) ->

  BTC_ADDRESS = "1MBXSHNF9ttQ6a3sbJ9M98tyqEFgt8LmVm"
  NICEHASH_URL = "https://new.nicehash.com"
  NICEHASH_MINER_PAGE_URL = NICEHASH_URL + "/miner/" + BTC_ADDRESS
  NICEHASH_API_URL = "https://api.nicehash.com/api"
  BTC_QUOTES_URL = "http://api.coindesk.com/v1/bpi/currentprice/EUR.json"

  robot.respond /rig/i, (msg) ->

    msg.send "Loading miner stats..."
    msg.http(NICEHASH_API_URL)
      .query(
        method: 'stats.provider.ex',
        addr: BTC_ADDRESS)
      .get() (err, res, body) ->

        miner = JSON.parse body
        current = JSON.stringify miner.result.current
        profitability = 0
        unpaid_balance = 0
        for algo in miner.result.current
          if Object.keys(algo.data[0]).length > 0
            msg.send "Running " + algo.name + " @ " + algo.data[0].a + " " + algo.suffix + "/s"
            profitability += (Number) algo.data[0].a * (Number) algo.profitability
          unpaid_balance += (Number) algo.data[1]

        msg.http(BTC_QUOTES_URL)
          .get() (err2, res2, body2) ->
            quotes = JSON.parse body2
            eurbtc = quotes.bpi.EUR.rate_float

            profit_eur = round(profitability * eurbtc, 2)
            unpaid_eur = round(unpaid_balance * eurbtc, 2)

            profit_mbtc = round(profitability * 1000, 5)
            unpaid_mbtc = round(unpaid_balance * 1000, 5)

            msg.send "Current profitability: " + profit_mbtc + " mBTC/day (" + profit_eur + " EUR/day)"
            msg.send "Unpaid balance: " + unpaid_mbtc + " mBTC (" + unpaid_eur + " EUR)"
            #msg.send "Source: " + NICEHASH_API_URL + "?method=stats.provider.ex&addr=" + BTC_ADDRESS
            msg.send "More info: " + NICEHASH_MINER_PAGE_URL
