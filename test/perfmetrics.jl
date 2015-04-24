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
    pnlfin = a1*(p2 - p1) + (a1 + a2)*(pexit - p2)

    metr = [:PnL]
    vt, perfm = TradingLogic.tradeperf(blotter, metr)
    ntrans = length(blotter)
    @fact length(vt) => ntrans

    @fact length(perfm[:PnL]) => ntrans

    @fact perfm[:Qty] => [a1, a2, -(a1 + a2)]
    @fact perfm[:FillPrice] => roughly([p1, p2, pexit])

    @fact perfm[:PnL] => roughly([0.0, a1*(p2 - p1), pnlfin])
    @fact TradingLogic.tradepnlfinal(blotter) => roughly(pnlfin)
  end
  context("Short enter and exit") do
    blotter = TradingLogic.emptyblotter()
    # short enter and exit price
    pent, pexit = 120.0, 115.2
    # short position held
    a = 100

    blotter[DateTime(2015,1,1,0)] = (-a, pent)
    blotter[DateTime(2015,1,1,1)] = (a, pexit)
    pnlfin = -a*(pexit - pent)

    metr = [:PnL]
    vt, perfm = TradingLogic.tradeperf(blotter, metr)
    ntrans = length(blotter)
    @fact length(vt) => ntrans

    @fact length(perfm[:PnL]) => ntrans

    @fact perfm[:Qty] => [-a, a]
    @fact perfm[:FillPrice] => roughly([pent, pexit])

    @fact perfm[:PnL] => roughly([0.0, pnlfin])
    @fact TradingLogic.tradepnlfinal(blotter) => roughly(pnlfin)
  end
  context("Long then short") do
    blotter = TradingLogic.emptyblotter()
    # prices and amounts
    p1, p2, p3 = 120.0, 85.0, 70.0
    along, ashort = 50, 70

    blotter[DateTime(2015,1,1,0)] = (along, p1)
    blotter[DateTime(2015,1,1,1)] = (-(along + ashort), p2)
    blotter[DateTime(2015,1,2)] = (0, p3) # e.g. stop backtest point
    losslong = along*(p2 - p1)
    pnlfin = losslong + ashort*(p2 - p3)

    metr = [:PnL]
    vt, perfm = TradingLogic.tradeperf(blotter, metr)
    ntrans = length(blotter)
    @fact length(vt) => ntrans

    @fact length(perfm[:PnL]) => ntrans

    @fact perfm[:Qty] => [along, -(along + ashort), 0]
    @fact perfm[:FillPrice] => roughly([p1, p2, p3])

    @fact perfm[:PnL] => roughly([0.0, losslong, pnlfin])
    @fact TradingLogic.tradepnlfinal(blotter) => roughly(pnlfin)
    #println(vt, perfm)
  end
end
