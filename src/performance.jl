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
                      dtformat::String = "yyy-mm-ddTHH:MM:SS",
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
Input `metrics` specifies what to calculate.
Returns: tuple ( DateTime (ordered) array , assoc. collection of perf metrics ).
Basic transaction info is also included (quantity, fill price).
"""
function tradeperf(blotter::Dict{DateTime,(Int64,Float64)},
                   metrics::Vector{Symbol})
  perfm = (Symbol=>Vector{Float64})[]
  ### TODO (later): accociative collections syntax changes in Julia 0.4

  # timestamps in order
  vt = vtblotter(blotter)
  nt = length(vt)

  # basic info for each transaction
  vqty, vprc = vapblotter(blotter)
  perfm[:Qty] = vqty
  perfm[:FillPrice] = vprc

  # PnL vector
  if findfirst(metrics, :PnL) > 0
    vm = zeros(nt)
    acsum = 0; pnlcsum = 0
    for i = 2:nt
      bprev = blotter[vt[i-1]]

      # lagged cumulative position held up to the current timestamp
      @inbounds acsum += bprev[1]

      # cumulative profit/loss at the current timestamp
      pnlcsum += acsum * (blotter[vt[i]][2] - bprev[2])
      @inbounds vm[i] = pnlcsum
    end
    perfm[:PnL] = vm
  end

  return vt, perfm
end

"""
Final profit/loss for `blotter` provided as
`DateTime => (Qty::Int64, FillPrice::Float64)` assoc. collection.
faster verision (minimizing memory allocation) to be used
in e.g. parameter optimization workflow.
Returns: final profit/loss `Float64` scalar.
"""
function tradepnlfinal(blotter::Dict{DateTime,(Int64,Float64)})
  # timestamps in order
  vt = vtblotter(blotter)
  nt = length(vt)

  acsum = 0; pnlcsum = 0
  for i = 2:nt
    bprev = blotter[vt[i-1]]

    # lagged cumulative position held up to the current timestamp
    @inbounds acsum += bprev[1]

    # cumulative profit/loss at the current timestamp
    pnlcsum += acsum * (blotter[vt[i]][2] - bprev[2])
  end

  return pnlcsum
end
