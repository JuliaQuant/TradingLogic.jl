"Ordered timestamps from blotter associative collection."
vtblotter(blotter::Dict{DateTime,(Int64,Float64)}) = sort!(collect(keys(blotter)))

"""
Amount `Vector{Int64)` and price `Vector{Float64)` from blotter
in chronological order (returns vector tuple).
"""
function vapblotter(blotter::Dict{DateTime,(Int64,Float64)})
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

"Print blotter transactions. Resembles DataFrames.printtable."
function printblotter(io::IO, blotter::Dict{DateTime,(Int64,Float64)};
                      dtformat::String = "yyyy-mm-ddTHH:MM:SS",
                      separator::Char = ',', quotemark::Char = '"')
  # ordered timestamps
  vt = vtblotter(blotter)
  nt = length(vt)

  # column names
  cnames = ["Timestamp", "Amount", "Price"]
  p = length(cnames)

  # print header
  for j in 1:p
    print(io, quotemark)
    print(io, cnames[j])
    print(io, quotemark)
    if j < p
      print(io, separator)
    else
      print(io, '\n')
    end
  end

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
function writeblotter(filename::String, blotter::Dict{DateTime,(Int64,Float64)};
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
function tradeperf(blotter::Dict{DateTime,(Int64,Float64)},
                   metrics::Vector{Symbol} = [:DDown])
  perfm = (Symbol=>Vector{Float64})[]
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
function apnlcum(blotter::Dict{DateTime,(Int64,Float64)})
  # timestamps in order
  vt = vtblotter(blotter)
  nt = length(vt)
  if nt == 0
    # no transactions yet
    return 0, 0.0, 0.0
  end

  acsum = 0; pnlcsum = 0
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
tradepnlfinal(blotter::Dict{DateTime,(Int64,Float64)}) = apnlcum(blotter)[2]

"Adding current price as the last timestamp."
function tradepnlfinal(blotter::Dict{DateTime,(Int64,Float64)}, pnow::Float64)
  # up to pcur
  acsumb, pnlb, pblast = apnlcum(blotter)

  # with pcur
  return pnlb + acsumb * (pnow - pblast)
end

"Performance metrics helper function for use in foldl."
function tradeperffold(perfprev::(Float64,Float64), statusnow::(Bool, Float64))
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
tradeperfcurr(s_status::Signal{(Bool, Float64)}) = foldl(tradeperffold, (0.0, 0.0), s_status)
