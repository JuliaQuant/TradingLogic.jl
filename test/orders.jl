facts("Order object methods") do
  context("Constructor checks") do
    @fact_throws TradingLogic.Order("error", 10, 150.0,
                                    :obscuresym,
                                    :market, :complete, "string")
    @fact_throws TradingLogic.Order("error", 10, 150.0,
                                    :buy, :obscuresym,
                                    :complete, "string")
    @fact_throws TradingLogic.Order("error", 10, 150.0,
                                    :buy, :market,
                                    :obscuresym, "string")
  end
  context("Get info and modify methods") do
    emptord = TradingLogic.emptyorder()
    @fact TradingLogic.getorderposchg(emptord) => 0
    @fact TradingLogic.ispending(emptord) => false
    emptord.status = :pending
    @fact TradingLogic.ispending(emptord) => true
    TradingLogic.setcancelled!(emptord)
    @fact TradingLogic.ispending(emptord) => false

    # targeted position change with proper sign
    emptord.side = :qq
    @fact_throws TradingLogic.getorderposchg(emptord)
    posord = TradingLogic.Order("pos", 10, 150.0,
                                :buy, :limit, :pending, "aux")
    negord = TradingLogic.Order("neg", 10, 150.0,
                                :sell, :limit, :pending, "aux")
    @fact TradingLogic.getorderposchg(posord) > 0 => true
    @fact TradingLogic.getorderposchg(negord) < 0 => true
  end
end

facts("Order handling based on target input") do
  context("Limit and marker order from target input") do
    nostoplim = Array(Float64, 0)
    ord = TradingLogic.emptyorder()
    # should not be calling targ2order! with zero position change
    @fact TradingLogic.targ2order!(ord, (0, nostoplim),
                                   "", 0, true) => false
    # stoplimit is not handled by targ2order!
    @fact TradingLogic.targ2order!(ord, (10, [1.0, 2.0]),
                                   "", 0, true) => false

    # when no limit price is given: submit market
    ord.ordertype = :limit
    qty = -10
    @fact TradingLogic.targ2order!(ord, (qty, nostoplim),
                                   "", 0, true) => true
    @fact ord.ordertype => :market
    @fact isnan(ord.price) => true
    @fact TradingLogic.getorderposchg(ord) => qty
    @fact ord.side => :sell
    @fact TradingLogic.ispending(ord) => true

    # limit order for submission
    ord = TradingLogic.emptyorder()
    @fact ord.ordertype => :market
    @fact ord.side => :buy
    @fact TradingLogic.ispending(ord) => false
    qty, prc = -50, 100.0
    @fact TradingLogic.targ2order!(ord, (qty, [prc]),
                                   "", 150, true) => true
    @fact ord.ordertype => :limit
    @fact isnan(ord.price) => false
    @fact ord.price => roughly(prc)
    @fact TradingLogic.getorderposchg(ord) => qty
    @fact ord.side => :sell
    @fact TradingLogic.ispending(ord) => true
  end

  # orderhandling! input
  tnow() = unix2datetime(time())
  tinit = tnow()
  posactual = [0]
  blotter = TradingLogic.emptyblotter()
  backtest = true

  context("Order handling: pending order now complete") do
    # any target (irrelevant at this step -> evaluated next step)
    targ = (0, Array(Float64, 0))

    # market order was pending
    ord = TradingLogic.Order("neg", 10, NaN, :sell,
                             :market, :pending, "aux")
    @fact TradingLogic.ispending(ord) => true
    @fact TradingLogic.orderhandling!(
      targ, 150.0, tinit, posactual, ord,
      blotter, backtest) => true
    # position updated, no new order generated yet
    # (need to re-evaluate target after position update)
    @fact blotter[tinit] => (-10, 150.0)
    @fact TradingLogic.ispending(ord) => false
    @fact posactual[1] => -10

    # same with limit-order that was pending
    #  and is satisfied at current price
    ord = TradingLogic.Order("pos", 10, 120.0, :buy,
                             :limit, :pending, "aux")
    @fact TradingLogic.ispending(ord) => true
    @fact TradingLogic.orderhandling!(
      targ, 110.0, tnow(), posactual, ord,
      blotter, backtest) => true
    # position updated, no new order generated yet
    # (need to re-evaluate target after position update)
    @fact TradingLogic.ispending(ord) => false
    @fact posactual[1] => 0
    @fact length(keys(blotter)) => 2
  end

  context("Order handling: no position change targeted") do
    targ = (0, Array(Float64, 0))

    # nothing was pending
    ord = TradingLogic.emptyorder()
    @fact TradingLogic.ispending(ord) => false
    @fact TradingLogic.orderhandling!(
      targ, 100.0, tnow(), posactual, ord,
      blotter, backtest) => true
    # now still nothing pending, actual position is the same
    @fact TradingLogic.ispending(ord) => false
    @fact posactual[1] => 0

    # order was pending that is still pending (limit)
    ord = TradingLogic.Order("pos", 10, 50.0, :buy,
                             :limit, :pending, "aux")
    @fact TradingLogic.ispending(ord) => true
    @fact TradingLogic.orderhandling!(
      targ, 100.0, tnow(), posactual, ord,
      blotter, backtest) => true
    # now pending order gets cancelled
    @fact TradingLogic.ispending(ord) => false
    @fact ord.status => :cancelled
    # no position updates
    @fact posactual[1] => 0
  end

  context("Order handling: market buy/sell") do
    targ = (10, Array(Float64, 0))

    # nothing was pending
    ord = TradingLogic.emptyorder()
    @fact TradingLogic.ispending(ord) => false
    @fact TradingLogic.orderhandling!(
      targ, 100.0, tnow(), posactual, ord,
      blotter, backtest) => true
    # now pending, actual position still the same
    @fact TradingLogic.ispending(ord) => true
    @fact ord.ordertype => :market
    @fact posactual[1] => 0

    # order was pending that is still pending (limit)
    ord = TradingLogic.Order("pos", 10, 50.0, :buy,
                             :limit, :pending, "aux")
    @fact TradingLogic.ispending(ord) => true
    @fact TradingLogic.orderhandling!(
      targ, 100.0, tnow(), posactual, ord,
      blotter, backtest) => true
    # now market target so cancel pending order
    @fact TradingLogic.ispending(ord) => false
    @fact ord.status => :cancelled
    # no position updates
    @fact posactual[1] => 0
  end

  context("Order handling: limit buy/sell") do
    targ = (30, [75.0])

    # nothing was pending
    ord = TradingLogic.emptyorder()
    @fact TradingLogic.ispending(ord) => false
    @fact TradingLogic.orderhandling!(
      targ, 100.0, tnow(), posactual, ord,
      blotter, backtest) => true
    # now limit pending, actual position still the same
    @fact TradingLogic.ispending(ord) => true
    @fact ord.ordertype => :limit
    @fact ord.side => :buy
    @fact posactual[1] => 0

    # limit order was pending that is still pending
    # in line with the target
    ord = TradingLogic.Order("pos", 30, 75.0, :buy,
                             :limit, :pending, "aux")
    @fact TradingLogic.orderhandling!(
      targ, 100.0, tnow(), posactual, ord,
      blotter, backtest) => true
    # leave it pending
    @fact TradingLogic.ispending(ord) => true
    @fact ord.ordertype => :limit
    @fact ord.side => :buy
    @fact posactual[1] => 0

    # limit order was pending that is still pending
    # position change not in line with the target (value)
    ord = TradingLogic.Order("pos", 25, 75.0, :buy,
                             :limit, :pending, "aux")
    @fact TradingLogic.orderhandling!(
      targ, 100.0, tnow(), posactual, ord,
      blotter, backtest) => true
    # cancel different order
    @fact TradingLogic.ispending(ord) => false
    @fact ord.status => :cancelled
    # no position updates
    @fact posactual[1] => 0

    # limit order was pending that is still pending
    # position change not in line with the target (side)
    ord = TradingLogic.Order("pos", 30, 75.0, :sell,
                             :limit, :pending, "aux")
    @fact TradingLogic.orderhandling!(
      targ, 70.0, tnow(), posactual, ord,
      blotter, backtest) => true
    # cancel different order
    @fact TradingLogic.ispending(ord) => false
    @fact ord.status => :cancelled
    # no position updates
    @fact posactual[1] => 0

    # limit order was pending that is still pending
    # limit price not in line with the target
    ord = TradingLogic.Order("pos", 30, 85.0, :buy,
                             :limit, :pending, "aux")
    @fact TradingLogic.orderhandling!(
      targ, 100.0, tnow(), posactual, ord,
      blotter, backtest) => true
    # cancel different order
    @fact TradingLogic.ispending(ord) => false
    @fact ord.status => :cancelled
    # no position updates
    @fact posactual[1] => 0
  end

  context("Order handling: stoplimit to track, buy-side") do
    targ = (50, [80.0, 75.0]) #[limitprice, stopprice]

    # nothing was pending
    # stop price not reached
    ord = TradingLogic.emptyorder()
    @fact TradingLogic.ispending(ord) => false
    @fact TradingLogic.orderhandling!(
      targ, 70.0, tnow(), posactual, ord,
      blotter, backtest) => true
    # no change, keep tracking the price
    @fact TradingLogic.ispending(ord) => false
    @fact posactual[1] => 0

    # nothing was pending
    # stop price reached
    ord = TradingLogic.emptyorder()
    @fact TradingLogic.ispending(ord) => false
    @fact TradingLogic.orderhandling!(
      targ, 75.1, tnow(), posactual, ord,
      blotter, backtest) => true
    # now limit pending, actual position still the same
    @fact TradingLogic.ispending(ord) => true
    @fact ord.ordertype => :limit
    @fact ord.side => :buy
    @fact ord.price => roughly(80.0)
    @fact posactual[1] => 0

    # limit order was pending that is still pending
    # stop price not reached
    ord = TradingLogic.Order("pos", 30, 65.0, :buy,
                             :limit, :pending, "aux")
    @fact TradingLogic.orderhandling!(
      targ, 70.0, tnow(), posactual, ord,
      blotter, backtest) => true
    # cancel previous order, keep tracking the price
    @fact TradingLogic.ispending(ord) => false
    @fact ord.status => :cancelled
    # no position updates
    @fact posactual[1] => 0

    # limit order was pending that is still pending
    # stop price reached
    # limit-target and prev. limit-pending can not match
    # (stop < limit for buy, sell symmetrically)
    # here we have (buy) limit_prev < stop < price_curr
    ord = TradingLogic.Order("pos", 50, 70.0, :buy,
                             :limit, :pending, "aux")
    @fact TradingLogic.orderhandling!(
      targ, 75.1, tnow(), posactual, ord,
      blotter, backtest) => true
    # cancel previous order with different limit-price
    @fact TradingLogic.ispending(ord) => false
    @fact ord.status => :cancelled
    # no position updates
    @fact posactual[1] => 0
  end

  context("Order handling: stoplimit to track, sell-side") do
    targ = (-50, [60.0, 75.0]) #[limitprice, stopprice]

    # nothing was pending
    # stop price not reached
    ord = TradingLogic.emptyorder()
    @fact TradingLogic.ispending(ord) => false
    @fact TradingLogic.orderhandling!(
      targ, 80.0, tnow(), posactual, ord,
      blotter, backtest) => true
    # no change, keep tracking the price
    @fact TradingLogic.ispending(ord) => false
    @fact posactual[1] => 0

    # nothing was pending
    # stop price reached
    ord = TradingLogic.emptyorder()
    @fact TradingLogic.ispending(ord) => false
    @fact TradingLogic.orderhandling!(
      targ, 74.9, tnow(), posactual, ord,
      blotter, backtest) => true
    # now limit pending, actual position still the same
    @fact TradingLogic.ispending(ord) => true
    @fact ord.ordertype => :limit
    @fact ord.side => :sell
    @fact ord.price => roughly(60.0)
    @fact posactual[1] => 0

    # limit order was pending that is still pending
    # stop price not reached
    ord = TradingLogic.Order("neg", 30, 85.0, :sell,
                             :limit, :pending, "aux")
    @fact TradingLogic.orderhandling!(
      targ, 80.0, tnow(), posactual, ord,
      blotter, backtest) => true
    # cancel previous order, keep tracking the price
    @fact TradingLogic.ispending(ord) => false
    @fact ord.status => :cancelled
    # no position updates
    @fact posactual[1] => 0

    # limit order was pending that is still pending
    # stop price reached
    # limit-target and prev. limit-pending can not match
    # (stop < limit for buy, sell symmetrically)
    # here we have (sell) limit_prev > stop > price_curr
    ord = TradingLogic.Order("neg", 50, 80.0, :sell,
                             :limit, :pending, "aux")
    @fact TradingLogic.orderhandling!(
      targ, 74.9, tnow(), posactual, ord,
      blotter, backtest) => true
    # cancel previous order with different limit-price
    @fact TradingLogic.ispending(ord) => false
    @fact ord.status => :cancelled
    # no position updates
    @fact posactual[1] => 0
  end
  #println(blotter)
end
