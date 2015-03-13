"""
Trade analysis for `blotter` provided as
`DateTime => (Qty::Int64, FillPrice::Float64)` assoc. collection.
Input `metrics` specifies what to calculate.
Returns: tuple ( DateTime (ordered) array , assoc. collection of perf metrics ).
"""
function tradeperf(blotter::Dict{DateTime,(Int64,Float64)},
                   metrics::Vector{Symbol})
  perfm = (Symbol=>Vector{Float64})[]
  ### TODO (later): accociative collections syntax changes in Julia 0.4

  # timestamps in order
  vt = sort!(collect(keys(blotter)))
  nt = length(vt)

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
  vt = sort!(collect(keys(blotter)))
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
