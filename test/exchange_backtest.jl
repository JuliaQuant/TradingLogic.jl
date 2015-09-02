facts("Exchange responses for backtesting") do
  context("Software-implemented limit order") do
    plim = 150.0
    buyord = TradingLogic.Order("buysome", 10, plim,
                                :buy, :limit, :pending, "aux")
    sellord = TradingLogic.Order("sellsome", 10, plim,
                                 :sell, :limit, :pending, "aux")
    @fact TradingLogic.plimitcheck(buyord, 175.0) --> false
    @fact TradingLogic.query_orderstatus(buyord, 175.0) --> :pending
    @fact TradingLogic.plimitcheck(buyord, 125.0) --> true
    @fact TradingLogic.query_orderstatus(buyord, 125.0) --> :complete
    @fact TradingLogic.plimitcheck(sellord, 175.0) --> true
    @fact TradingLogic.query_orderstatus(sellord, 175.0) --> :complete
    @fact TradingLogic.plimitcheck(sellord, 125.0) --> false
    @fact TradingLogic.query_orderstatus(sellord, 125.0) --> :pending
  end
  context("Market order and order submission") do
    ordid = "markord"
    mord = TradingLogic.Order(ordid, 10, NaN,
                              :buy, :market, :pending, "aux")
    # buy no matter how high
    @fact TradingLogic.query_orderstatus(mord, 1e7) --> :complete
    # simulated order submission
    @fact TradingLogic.submit_ordernew(mord, false) --> "FAIL"
    @fact TradingLogic.submit_ordernew(mord, true) --> ordid
  end
  context("Cancel pending limit-order") do
    limord = TradingLogic.Order("buysome", 10, 100.0,
                                :buy, :limit, :pending, "aux")
    @fact TradingLogic.submit_ordercancel(limord) --> true
    # can not cancel non-pending order
    @fact TradingLogic.submit_ordercancel(
      TradingLogic.emptyorder()) --> false
  end
end
