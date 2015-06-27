abstract TradingStructures
### TODO (later) use a suitable Blotter/FinancialSeries abstract type

"Order type"
type Order <: TradingStructures
  id::ASCIIString # unique order id for submission/tracking
  quantity::Int64 # abs. value of position change targeted
  price::Float64 # limit price, set to NaN for market order
  side::Symbol # :buy :sell (no need for :short <=> {position = 0 with sell})
  ordertype::Symbol # :market :limit
  status::Symbol # :pending :complete :cancelled
  trigger::ASCIIString # custom string for tracking what triggered the order

  function Order(id::ASCIIString, quantity::Int64, price::Float64,
                 side::Symbol, ordertype::Symbol, status::Symbol,
                 trigger::ASCIIString)
    (side == :buy || side == :sell) || error("Unknown order side")
    (ordertype == :market || ordertype == :limit) || error("Unsupported order type")
    if !(status == :pending || status == :complete || status == :cancelled)
      error("Unsupported order status")
    end
    new(id, quantity, price, side, ordertype, status, trigger)
  end
end

"Empty order: no quantity"
emptyorder() = Order("empty", 0, NaN, :buy, :market, :complete, "init")

"Check if order status is `:pending`"
ispending(orde::Order) = orde.status == :pending

"Change order status to `:cancelled`"
function setcancelled!(orde::Order)
  orde.status = :cancelled
  return
end

"Signed position change in the Order object"
function getorderposchg(orde::Order)
  if orde.side == :buy
    return orde.quantity
  end
  if orde.side == :sell
    return -orde.quantity
  end
  error("Unknown order side")
end

typealias Blotter @compat Dict{DateTime,Tuple{Int64,Float64}}

typealias Targ @compat Tuple{Int64,Vector{Float64}}

typealias OHLC @compat Tuple{DateTime,Vector{Float64}}

"""
Initialize empty blotter as an associative collection
`DateTime => (Qty::Int64, FillPrice::Float64)`
"""
emptyblotter() = Blotter()
### TODO (later): accociative collections syntax changes in Julia 0.4



# "Completed (closed) trade type."
# immutable ClosedTrade
#   topen::DateTime
#   tclose::DateTime
#   popen::Float64
#   pclose::Float64
#   tradeside::Symbol
#   tradequantity::Int64
# end



# """
# Array-like type keeping all open trades,
# thus holding current (actual) position information with open prices.
# Multiple entries may appear when an order is filled in parts.
# """
# immutable OpenTrades <: TradingStructures
#   quantities::Vector{Int64} # abs. value of outstanding position
#   openprices::Vector{Float64}
#   sides::Vector{Symbol} # :long :short

#   ### TODO inner constructor checks (similar to TimeArray in TimeSeries.jl)
# end

# "OpenTrades object without outstanding position"
# emptyopentrades() = OpenTrades([0], [NaN], [:long])

# "Get total outstanding position from `OpenTrades`-object."
# getopenposition(otrades::OpenTrades) = sum(otrades.quantities)


### use array of Trade-objects instead of what is below?
### (append closed trades to it)

# """
# Array type keeping trades information, both open and completed.
# Since it contains open trades, it holds
# current (actual) position information with open prices.
# Multiple open entries may appear when an order is filled in parts.
# """
# immutable TradesArray <: TradingStructures
#   entertimes::Vector{DateTime}
#   exittimes::Union(Vector{DateTime}, Symbol) # :open of exit DateTime
#   quantities::Vector{Int64} # abs. value of outstanding position
#   openprices::Vector{Float64}
#   closeprices::Vector{Float64}
#   sides::Vector{Symbol} # :long :short

#   ### TODO inner constructor checks (similar to TimeArray in TimeSeries.jl)
# end

# "Empty TradesArray object"
# emptytrades() = TradesArray(Array(DateTime, 0), Array(DateTime, 0),
#                             Array(Int64, 0),
#                             Array(Float64, 0), Array(Float64, 0),
#                             Array(Symbol, 0))

# "Get total outstanding position from `TradesArray`-object."
# getopenposition(trarr::TradesArray) = sum(otrades.quantities)
