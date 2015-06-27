include("types.jl")

"Ordered timestamps from blotter associative collection."
vtblotter(blotter::Blotter) = sort!(collect(keys(blotter)))

"""
Amount `Vector{Int64)` and price `Vector{Float64)` from blotter
in chronological order (returns vector tuple).
"""
function vapblotter(blotter::Blotter)
  vt = vtblotter(blotter)
  nt = length(vt)
  vqty = Array(Int64, nt)
  vprc = zeros(nt)
  for i = 1:nt
    ti = vt[i]
    bi = blotter[ti]
    @inbounds vqty[i] = bi[1]
    @inbounds vprc[i] = bi[2]
  end
  return vqty, vprc
end

"Print a text line from string vector."
function printvecstring(io, vstring::Vector,
                        separator::Char, quotemark::Char)
  p = length(vstring)
  for j in 1:p
    print(io, quotemark)
    print(io, vstring[j])
    print(io, quotemark)
    if j < p
      print(io, separator)
    else
      print(io, '\n')
    end
  end
  return
end

"Print blotter transactions. Resembles DataFrames.printtable."
function printblotter(io::IO, blotter::Blotter;
                      dtformat::String = "yyyy-mm-ddTHH:MM:SS",
                      separator::Char = ',', quotemark::Char = '"')
  # ordered timestamps
  vt = vtblotter(blotter)
  nt = length(vt)

  # column names: print header
  cnames = ["Timestamp", "Amount", "Price"]
  printvecstring(io, cnames, separator, quotemark)

  # print contents
  for ti in vt
    # timestamp
    print(io, quotemark)
    print(io, Dates.format(ti, dtformat))
    print(io, quotemark)
    print(io, separator)
    # amount and price
    bi = blotter[ti]
    print(io, bi[1])
    print(io, separator)
    print(io, bi[2])
    print(io, '\n')
  end

  return
end

"Write blotter transactions to file."
function writeblotter(filename::String, blotter::Blotter;
                      dtformat::String = "yyy-mm-ddTHH:MM:SS",
                      separator::Char = ',', quotemark::Char = '"')
  open(filename, "w") do io
    printblotter(io, blotter,
                 dtformat=dtformat, separator=separator, quotemark=quotemark)
  end
  return
end

"""
Trade analysis for `blotter` provided as
`DateTime => (Qty::Int64, FillPrice::Float64)` assoc. collection.
Input `metrics` specifies what to calculate (PnL included already - others).
Returns: tuple ( DateTime (ordered) array , assoc. collection of perf metrics ).
Basic transaction info is also included (quantity, fill price).

**CAUTION**: PnL and drawdown are calculated here based on the transaction blotter
only, not the price history. Hence, price swing effects while holding
an open position are not showing up in the results. Use `orderhandling!`
output if performance metrics over the whole price history are needed
(as typically done when analyzing PnL and drawdown).
"""
function tradeperf(blotter::Blotter,
                   metrics::Vector{Symbol} = [:DDown])
  perfm = Dict{Symbol,Vector{Float64}}()
  ### TODO (later): accociative collections syntax changes in Julia 0.4

  # timestamps in order
  vt = vtblotter(blotter)
  nt = length(vt)

  # basic info for each transaction
  vqty, vprc = vapblotter(blotter)
  perfm[:Qty] = vqty
  perfm[:FillPrice] = vprc

  # PnL and return-based drawdown (always calculating those metrics)
  vpl = zeros(nt); vdd = zeros(nt)
  acsum = 0; pnlcsum = 0.0; pnlcmax = 0.0
  for i = 2:nt
    bprev = blotter[vt[i-1]]

    # lagged cumulative position held up to the current timestamp
    @inbounds acsum += bprev[1]

    # cumulative profit/loss at the current timestamp
    pnlcsum += acsum * (blotter[vt[i]][2] - bprev[2])
    @inbounds vpl[i] = pnlcsum

    # return-based drawdown
    if pnlcsum > pnlcmax # positive or negative
      pnlcmax = pnlcsum
    end
    @inbounds vdd[i] = pnlcsum - pnlcmax
  end
  perfm[:PnL] = vpl

  # return-based drawdown
  if findfirst(metrics, :DDown) > 0
    perfm[:DDown] = vdd
  end

  return vt, perfm
end

"Cumulative position, profit/loss, last fill price for blotter."
function apnlcum(blotter::Blotter)
  # timestamps in order
  vt = vtblotter(blotter)
  nt = length(vt)
  if nt == 0
    # no transactions yet
    return 0, 0.0, 0.0
  end

  acsum = 0; pnlcsum = 0.0
  for i = 2:nt
    bprev = blotter[vt[i-1]]

    # lagged cumulative position held up to the current timestamp
    @inbounds acsum += bprev[1]

    # cumulative profit/loss at the current timestamp
    pnlcsum += acsum * (blotter[vt[i]][2] - bprev[2])
  end

  blast = blotter[vt[nt]]
  return acsum + blast[1], pnlcsum, blast[2]
end

"""
Final profit/loss for `blotter` provided as
`DateTime => (Qty::Int64, FillPrice::Float64)` assoc. collection.
Faster verision (minimizing memory allocation) to be used
in e.g. parameter optimization workflow.

Returns: final profit/loss `Float64` scalar.
"""
:tradepnlfinal

"Based on blotter only, ending at the last transaction timestamp."
tradepnlfinal(blotter::Blotter) = apnlcum(blotter)[2]

"Adding current price as the last timestamp."
function tradepnlfinal(blotter::Blotter, pnow::Float64)
  # up to pcur
  acsumb, pnlb, pblast = apnlcum(blotter)

  # with pcur
  return pnlb + acsumb * (pnow - pblast)
end

"Performance metrics helper function for use in foldl."
function tradeperffold(perfprev::@compat(Tuple{Float64,Float64}), statusnow::@compat(Tuple{Bool, Float64}))
  # current max. PnL
  pnlprev = perfprev[1]
  pnlnow = statusnow[2]
  pnlcummax = pnlnow > pnlprev ? pnlnow : pnlprev

  # current return-based drawdown
  ddnow = abs(pnlnow - pnlcummax)

  # maximum drawdown
  ddprev = perfprev[2]
  ddmax = ddnow > ddprev ? ddnow : ddprev

  return pnlcummax, ddmax
end

"""
Selected performance metrics from `runtrading!` signal output.

Output tuple-signal components:

* `Float64` cumulative maximum PnL;
* `Float64` maximum drawdown over the entire trading session hisotry.

NOTE: Use this function only if needed, otherwise save resources; it is
not required for running the trading session.
"""
tradeperfcurr(s_status::Signal{@compat(Tuple{Bool, Float64})}) = foldl(tradeperffold, (0.0, 0.0), s_status)

"""
Selected metrics for completed trades out of transactions blotter.

Return tuple contains:

- `Vector{Float64}` profit/loss for each completed trade;
- `Int64` number of winning trades;
- `Float64` average winning trade profit;
- `Int64` number of loosing trades;
- `Float64` average loosing trade loss.
"""
function vtradespnl(blotter::Blotter)
  # timestamps in order
  vt = vtblotter(blotter)
  nt = length(vt)
  if nt == 0
    # no transactions
    return Array(Float64, 0), 0, 0.0, 0, 0.0
  end

  vtrpnl = Array(Float64, 0)
  acsum = 0; pnlcsum = 0.0
  pnlcsum_trprevend = 0.0
  ntrpos = 0; ntrneg = 0
  profcum_trpos = 0.0; losscum_trneg = 0.0
  for i = 2:nt
    bprev = blotter[vt[i-1]]; bnow = blotter[vt[i]]
    # lagged cumulative position held up to the current timestamp
    @inbounds acsum += bprev[1]
    # cumulative profit/loss at the current timestamp
    pnlcsum += acsum * (bnow[2] - bprev[2])

    # new position based on the current transaction amount
    posi = acsum + bnow[1]
    if posi == 0 || sign(posi) == -sign(acsum)
      # trade completed at the current timestep
      pnli = pnlcsum - pnlcsum_trprevend
      pnlcsum_trprevend = pnlcsum
      push!(vtrpnl, pnli)
      if pnli > 0.0
        # winning trade
        ntrpos += 1
        profcum_trpos += pnli
      else
        # loosing trade
        ntrneg += 1
        losscum_trneg += abs(pnli)
      end
    end
  end

  if ntrpos < 1
    avwin = 0.0
  else
    avwin = profcum_trpos / ntrpos
  end
  if ntrneg < 1
    avloss = 0.0
  else
    avloss = losscum_trneg / ntrneg
  end

  return vtrpnl, ntrpos, avwin, ntrneg, avloss
end

"""
Pessimistic return on margin `marg`.

For `pror = true` returns pessimistic rate of return (can be thought of as
a more realistic profit factor).

Optional `nbest_remove` argument specifies how many best wins
are dropped (to increase PROM strictness).

**CAUTION** `-Inf` returned if `nbest_remove` exceeds the
total number of trades.
"""
:perf_prom

"Pessimistic rate of return with extreme case handling."
function perf_pror_auxil(ppos::Float64, pneg::Float64)
  if abs(pneg) < eps() && abs(ppos) < eps()
    # 0/0 situation: no profit anyway
    return 0.0
  end
  # with finite ppos +/-Inf is acceptable if pneg=0
  return ppos/pneg
end

"From blotter using completed trades."
function perf_prom(blotter::Blotter;
                   pror::Bool = false,
                   marg::Float64 = 1.0,
                   nbest_remove::Int64 = 0)
  marg = abs(marg) # positive denominator
  vtrpnl, ntrpos, avwin, ntrneg, avloss = vtradespnl(blotter)

  if nbest_remove == 0
    ppos = avwin*(ntrpos - sqrt(float(ntrpos)))
    pneg = avloss*(ntrneg + sqrt(float(ntrneg)))
    if pror
      return perf_pror_auxil(ppos, pneg)
    else
      return (ppos - pneg) / marg
    end
  end
  return perf_prom(vtrpnl, marg = marg, pror = pror, nbest_remove = nbest_remove)
end

"From profit/loss vector of completed trades."
function perf_prom(vtrpnl::Vector{Float64};
                   marg::Float64 = 1.0,
                   pror::Bool = false,
                   nbest_remove::Int64 = 0)
  ntr = length(vtrpnl)
  marg = abs(marg) # positive denominator
  if ntr < 1
    # no trades
    return 0.0
  end

  if nbest_remove > 0
    if ntr <= nbest_remove
      return -Inf
    end
    pnllim = sort(vtrpnl, rev=true)[nbest_remove]
  else
    # no trades are dropped: not limiting PnL
    pnllim = Inf
  end

  ntrpos = 0; ntrneg = 0
  profcum_trpos = 0.0; losscum_trneg = 0.0
  for pnli in vtrpnl
    # take into account PnL limit after best trades removal
    if 0.0 < pnli < pnllim
      ntrpos += 1
      profcum_trpos += pnli
    end
    if pnli < 0.0
      ntrneg += 1
      losscum_trneg += abs(pnli)
    end
  end

  if ntrpos < 1
    avwin = 0.0
  else
    avwin = profcum_trpos / ntrpos
  end
  if ntrneg < 1
    avloss = 0.0
  else
    avloss = losscum_trneg / ntrneg
  end

  ppos = avwin*(ntrpos - sqrt(ntrpos))
  pneg = avloss*(ntrneg + sqrt(ntrneg))
  if pror
    return perf_pror_auxil(ppos, pneg)
  end
  return (ppos - pneg) / marg
end
