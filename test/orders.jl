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
#   context("Limit and marker order from target input") do
#     nostoplim = Array(Float64, 0)
#     ord = TradingLogic.emptyorder()
#     # should not be calling targ2order! with zero position change
#     @fact TradingLogic.targ2order!(ord, (0, nostoplim),
#                                    "", 0, true) => false
#     # stoplimit is not handled by targ2order!
#     @fact TradingLogic.targ2order!(ord, (10, [1.0, 2.0]),
#                                    "", 0, true) => false

#     # when no limit price is given: submit market
#     ord.ordertype = :limit
#     qty = -10
#     @fact TradingLogic.targ2order!(ord, (qty, nostoplim),
#                                    "", 0, true) => true
#     @fact ord.ordertype => :market
#     @fact isnan(ord.price) => true
#     @fact TradingLogic.getorderposchg(ord) => qty
#     @fact ord.side => :sell
#     @fact TradingLogic.ispending(ord) => true

#     # limit order for submission
#     ord = TradingLogic.emptyorder()
#     @fact ord.ordertype => :market
#     @fact ord.side => :buy
#     @fact TradingLogic.ispending(ord) => false
#     qty, prc = -50, 100.0
#     @fact TradingLogic.targ2order!(ord, (qty, [prc]),
#                                    "", 150, true) => true
#     @fact ord.ordertype => :limit
#     @fact isnan(ord.price) => false
#     @fact ord.price => roughly(prc)
#     @fact TradingLogic.getorderposchg(ord) => qty
#     @fact ord.side => :sell
#     @fact TradingLogic.ispending(ord) => true
#   end

  # orderhandling! input
  tnow() = unix2datetime(time())
  tinit = tnow()
  posactual = [0]
  blotter = TradingLogic.emptyblotter()
  backtest = true

  context("Order handling: no position change targeted") do
    ### verify no change

    ### then: verify if was pending, now cancelled



    @fact 0 => 1
  end

  context("Order handling: market buy/sell") do
    targ = (10, Array(Float64, 0))

    # nothing was pending
    ord = TradingLogic.emptyorder()
    @fact TradingLogic.ispending(ord) => false
    @fact TradingLogic.orderhandling!(
      targ, 100.0, tinit, posactual, ord,
      blotter, backtest) => true
    @fact TradingLogic.ispending(ord) => true
    # now pending, actual position still the same
    @fact ord.ordertype => :market
    @fact posactual[1] => 0

    # order was pending that is now complete
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

    # order was pending that is still pending (limit)
    # now market target so cancel pending order
    ord = TradingLogic.Order("pos", 10, 50.0, :buy,
                             :limit, :pending, "aux")
    @fact TradingLogic.ispending(ord) => true
    @fact TradingLogic.orderhandling!(
      targ, 100.0, tnow(), posactual, ord,
      blotter, backtest) => true
    @fact TradingLogic.ispending(ord) => false
    # no position updates
    @fact posactual[1] => 0
    # now it is cancelled order
    @fact ord.status => :cancelled



    # different type order was pending: cancel it
    ### was limit, now market in target
    ### get status first, reposition if needed #############

    # order:

    # pending order different from the target position: cancel

    println(blotter)

    ###
    @fact 0 => 1
  end

  context("Order handling: limit buy/sell") do
    @fact 0 => 1

    # order was pending that is still pending,
    #  in line with the target: leave it pending
    ### if same exact limit price, different lim price -> cancel
  end

  context("Order handling: stoplimit to track") do
    @fact 0 => 1
  end
end
