facts("Trading metrics from transactions blotter") do
  context("Transaction blotter transformations") do
    blotter = TradingLogic.emptyblotter()

    # long than short with exit
    p1, p2, p3 = 108.0, 85.0, 74.0
    along, ashort = 50, 70
    tlong = Dates.DateTime(2015,1,1,3,8,17)
    tshort = Dates.DateTime(2015,1,1,5,2,4)
    texit = Dates.DateTime(2015,1,3,15,12,48)

    # enter transactions not in chronological order
    blotter[tshort] = (-(along + ashort), p2)
    blotter[tlong] = (along, p1)
    blotter[texit] = (ashort, p3)
    TradingLogic.printblotter(STDOUT, blotter)

    # sorted vectors
    @fact TradingLogic.vtblotter(blotter) => [tlong, tshort, texit]
    va, vp = TradingLogic.vapblotter(blotter)
    @fact va => [along, -(along + ashort), ashort]
    @fact vp => roughly([p1, p2, p3])

    # print to file
    dtfmt = "yyyy-mm-dd HH:MM:SS" # not default
    fnm = "writetest.csv"
    TradingLogic.writeblotter(fnm, blotter, dtformat = dtfmt)
    rcsv = readcsv(fnm)
    run(`rm $fnm`)
    @fact size(rcsv) => (4,3)
    @fact rcsv[1,2] => "Amount"
    @fact rcsv[2,1] => Dates.format(tlong, dtfmt)
    @fact rcsv[4,1] => Dates.format(texit, dtfmt)
    @fact int(rcsv[3,2]) => -(along + ashort)
    @fact float(rcsv[4,3]) => roughly(p3)
  end
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
