facts("Trading metrics from transactions blotter") do
  context("Long enter with partial fill") do
    blotter = TradingLogic.emptyblotter()
    # fill prices and exit price
    p1, p2, pexit = 120.0, 135.0, 150.0
    # amounts
    a1, a2 = 20, 30

    blotter[DateTime(2015,1,1,0)] = (a1, p1)
    blotter[DateTime(2015,1,1,1)] = (a2, p2)
    blotter[DateTime(2015,1,2)] = (-(a1 + a2), pexit)

    metr = [:PnL]
    vt, perfm = TradingLogic.tradeperf(blotter, metr)
    ntrans = length(blotter)
    @fact length(vt) => ntrans

    @fact length(perfm[:PnL]) => ntrans
    @fact perfm[:PnL] => roughly([0.0, a1*(p2 - p1),
                                 a1*(p2 - p1) + (a1 + a2)*(pexit - p2)])
  end
  context("Short enter and exit") do
    blotter = TradingLogic.emptyblotter()
    # short enter and exit price
    pent, pexit = 120.0, 115.2
    # short position held
    a = 100

    blotter[DateTime(2015,1,1,0)] = (-a, pent)
    blotter[DateTime(2015,1,1,1)] = (a, pexit)

    metr = [:PnL]
    vt, perfm = TradingLogic.tradeperf(blotter, metr)
    ntrans = length(blotter)
    @fact length(vt) => ntrans

    @fact length(perfm[:PnL]) => ntrans
    @fact perfm[:PnL] => roughly([0.0, -a*(pexit - pent)])
  end
  context("Long then short") do
    blotter = TradingLogic.emptyblotter()
    # prices and amounts
    p1, p2, p3 = 120.0, 85.0, 70.0
    along, ashort = 50, 70

    blotter[DateTime(2015,1,1,0)] = (along, p1)
    blotter[DateTime(2015,1,1,1)] = (-(along + ashort), p2)
    blotter[DateTime(2015,1,2)] = (0, p3) # e.g. stop backtest point

    metr = [:PnL]
    vt, perfm = TradingLogic.tradeperf(blotter, metr)
    ntrans = length(blotter)
    @fact length(vt) => ntrans

    @fact length(perfm[:PnL]) => ntrans
    losslong = along*(p2 - p1)
    @fact perfm[:PnL] => roughly([0.0, losslong,
                                 losslong + ashort*(p2 - p3)])
    #println(vt, perfm)
  end
end
