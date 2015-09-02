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
    @fact TradingLogic.vtblotter(blotter) --> [tlong, tshort, texit]
    va, vp = TradingLogic.vapblotter(blotter)
    @fact va --> [along, -(along + ashort), ashort]
    @fact vp --> roughly([p1, p2, p3])

    # print to file
    dtfmt = "yyyy-mm-dd HH:MM:SS" # not default
    fnm = "writetest.csv"
    TradingLogic.writeblotter(fnm, blotter, dtformat = dtfmt)
    rcsv = readcsv(fnm)
    run(`rm $fnm`)
    @fact size(rcsv) --> (4,3)
    @fact rcsv[1,2] --> "Amount"
    @fact rcsv[2,1] --> Dates.format(tlong, dtfmt)
    @fact rcsv[4,1] --> Dates.format(texit, dtfmt)
    @fact int(rcsv[3,2]) --> -(along + ashort)
    @fact float(rcsv[4,3]) --> roughly(p3)
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

    metr = [:DDown]
    vt, perfm = TradingLogic.tradeperf(blotter, metr)
    ntrans = length(blotter)
    @fact length(vt) --> ntrans

    @fact length(perfm[:PnL]) --> ntrans

    @fact perfm[:Qty] --> [a1, a2, -(a1 + a2)]
    @fact perfm[:FillPrice] --> roughly([p1, p2, pexit])

    @fact perfm[:PnL] --> roughly([0.0, a1*(p2 - p1), pnlfin])
    @fact TradingLogic.tradepnlfinal(blotter) --> roughly(pnlfin)
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

    metr = [:DDown]
    vt, perfm = TradingLogic.tradeperf(blotter, metr)
    ntrans = length(blotter)
    @fact length(vt) --> ntrans

    @fact length(perfm[:PnL]) --> ntrans

    @fact perfm[:Qty] --> [-a, a]
    @fact perfm[:FillPrice] --> roughly([pent, pexit])

    @fact perfm[:PnL] --> roughly([0.0, pnlfin])
    @fact TradingLogic.tradepnlfinal(blotter) --> roughly(pnlfin)
  end
  context("Long then short") do
    blotter = TradingLogic.emptyblotter()
    # prices and amounts
    p1, p2, p3 = 120.0, 85.0, 70.0
    along, ashort = 50, 70

    losslong = along*(p2 - p1)
    pnlfin = losslong + ashort*(p2 - p3)

    blotter[DateTime(2015,1,1,0)] = (along, p1)
    blotter[DateTime(2015,1,1,1)] = (-(along + ashort), p2)

    # not yet final PnL with incomplete blotter
    @fact abs(TradingLogic.tradepnlfinal(blotter) - pnlfin) > 10.0 --> true
    # test tradepnlfinal method with pnow: final PnL
    #  doing this before adding the final (exit) transaction to blotter
    @fact TradingLogic.tradepnlfinal(blotter, p3) --> roughly(pnlfin)

    # final transaction (e.g. stop backtest point)
    blotter[DateTime(2015,1,2)] = (0, p3)

    metr = [:DDown]
    vt, perfm = TradingLogic.tradeperf(blotter, metr)
    #println(vt, perfm)
    ntrans = length(blotter)
    @fact length(vt) --> ntrans
    @fact length(perfm[:PnL]) --> ntrans

    @fact perfm[:Qty] --> [along, -(along + ashort), 0]
    @fact perfm[:FillPrice] --> roughly([p1, p2, p3])

    @fact perfm[:PnL] --> roughly([0.0, losslong, pnlfin])
    @fact TradingLogic.tradepnlfinal(blotter) --> roughly(pnlfin)

    # return-based drawdown
    ddmax = abs(losslong)
    @fact perfm[:DDown] --> roughly([0.0, -ddmax, -abs(pnlfin)])
  end
end

facts("Running performance metrics") do
  context("Current maximum PnL and drawdown over trading history") do
    pnl_dd_max = TradingLogic.tradeperffold((10.0, 0.0), (true, 15.0))
    @fact pnl_dd_max[1] --> roughly(15.0)
    @fact pnl_dd_max[2] --> roughly(0.0)

    pnl_dd_max = TradingLogic.tradeperffold((10.0, 20.0), (true, 15.0))
    @fact pnl_dd_max[1] --> roughly(15.0)
    @fact pnl_dd_max[2] --> roughly(20.0)

    pnl_dd_max = TradingLogic.tradeperffold((10.0, 0.0), (true, 5.0))
    @fact pnl_dd_max[1] --> roughly(10.0)
    @fact pnl_dd_max[2] --> roughly(5.0)

    pnl_dd_max = TradingLogic.tradeperffold((10.0, 50.0), (true, 5.0))
    @fact pnl_dd_max[1] --> roughly(10.0)
    @fact pnl_dd_max[2] --> roughly(50.0)
  end
end

facts("Trades and corresponding metrics from transactions blotter") do
  blotter = TradingLogic.emptyblotter()
  dthour(h::Int64) = Dates.DateTime(2015,6,1,h)
  blotter[dthour(1)] = (25, 85.0)
  blotter[dthour(2)] = (25, 95.0)
  blotter[dthour(3)] = (-60, 100.0)
  blotter[dthour(4)] = (20, 80.0)
  blotter[dthour(5)] = (-10, 75.0)
  blotter[dthour(6)] = (10, 85.0)
  blotter[dthour(7)] = (-10, 70.0)
  blotter[dthour(8)] = (-50, 65.0)
  blotter[dthour(11)] = (50, 25.0)
  # open trade
  blotter[dthour(12)] = (20, 35.0)
  #TradingLogic.printblotter(STDOUT, blotter)
  @fact TradingLogic.tradepnlfinal(blotter) --> roughly(2500.0)

  context("Trades PnL vector with selected metrics from blotter") do
    vtrpnl, ntrpos, avwin, ntrneg, avloss = TradingLogic.vtradespnl(blotter)
    @fact length(vtrpnl) --> 5
    @fact sum(vtrpnl) --> roughly(2500.0)
    @fact ntrpos --> 3
    @fact avwin --> roughly(900.0)
    @fact ntrneg --> 2
    @fact avloss --> roughly(100.0)
  end

  context("Trades-based performance metrics: PROM") do
    marg = 5e3

    # no transactions
    @fact TradingLogic.perf_prom(
      TradingLogic.emptyblotter()) --> roughly(0.0)

    # from blotter, using all completed trades
    prom0 = ((3.0 - sqrt(3.0))*900.0 - (2.0 + sqrt(2.0))*100.0)/marg
    @fact TradingLogic.perf_prom(blotter, marg=marg) --> roughly(prom0)

    # removing specific number of best wins
    prom1 = ((2.0 - sqrt(2.0))*350.0 - (2.0 + sqrt(2.0))*100.0)/marg
    @fact TradingLogic.perf_prom(blotter, marg=marg,
                                 nbest_remove = 1) --> roughly(prom1)

    # from trades PnL vector
    vtrpnl, ntrpos, avwin, ntrneg, avloss = TradingLogic.vtradespnl(blotter)
    @fact TradingLogic.perf_prom(vtrpnl, marg=marg,
                                 nbest_remove = 1) --> roughly(prom1)
    prom2 = -(2.0 + sqrt(2.0))*100.0/marg
    @fact TradingLogic.perf_prom(vtrpnl, marg=marg,
                                 nbest_remove = 2) --> roughly(prom2)
    # if asking to remove more best wins than the total number of wins
    prom = TradingLogic.perf_prom(vtrpnl, marg=marg, nbest_remove = 5)
    # -Inf
    @fact prom < 0.0 --> true
    @fact isfinite(prom) --> false
    prom = TradingLogic.perf_prom(vtrpnl, marg=marg, nbest_remove = 6)
    # -Inf
    @fact prom < 0.0 --> true
    @fact isfinite(prom) --> false
  end

  context("Trades-based performance metrics: PROR") do
    pror0 = (3.0 - sqrt(3.0))*900.0 / ((2.0 + sqrt(2.0))*100.0)
    @fact TradingLogic.perf_prom(blotter, pror=true) --> roughly(pror0)
    pror1 = (2.0 - sqrt(2.0))*350.0 / ((2.0 + sqrt(2.0))*100.0)
    @fact TradingLogic.perf_prom(blotter, pror=true,
                                 nbest_remove = 1) --> roughly(pror1)

    # PROR without profits
    @fact TradingLogic.perf_prom(TradingLogic.emptyblotter(),
                                 pror=true) --> roughly(0.0)
    @fact TradingLogic.perf_prom(Array(Float64,0), pror=true) --> roughly(0.0)
    @fact TradingLogic.perf_prom([-2.0], pror=true) --> roughly(0.0)
    pror = TradingLogic.perf_prom([-2.0], pror=true, nbest_remove = 1)
    # -Inf
    @fact pror < 0.0 --> true
    @fact isfinite(pror) --> false

    # PROR without profits or losses: 1 - sqrt(1)
    @fact TradingLogic.perf_prom([5.0, -2.0], pror=true) --> roughly(0.0)
    @fact TradingLogic.perf_prom([5.0, -2.0], pror=true,
                                 nbest_remove = 1) --> roughly(0.0)
    # PROR without losses
    pror = TradingLogic.perf_prom([5.0, 2.0], pror=true, nbest_remove = 0)
    # +Inf
    @fact pror < 0.0 --> false
    @fact isfinite(pror) --> false
    @fact TradingLogic.perf_prom([5.0, 2.0], pror=true,
                                 nbest_remove = 1) --> roughly(0.0)
    pror = TradingLogic.perf_prom([5.0, 2.0], pror=true, nbest_remove = 2)
    # -Inf
    @fact pror < 0.0 --> true
    @fact isfinite(pror) --> false
  end
end
