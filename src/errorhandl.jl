## error handling

function tradesyserror(statussignal::Bool)
  if !statussignal
    println("Trading system error encountered")
  end
  return statussignal
end
