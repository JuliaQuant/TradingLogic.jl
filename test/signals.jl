using TradingLogic
using Reactive

facts("Working with signals") do
  context("Change detection") do
    s_inp = Reactive.Input(5)
    s_chg = TradingLogic.schange(s_inp)
    push!(s_inp, 5)
    @fact s_chg.value --> false
    push!(s_inp, 8)
    @fact s_chg.value --> true
    push!(s_inp, 8)
    @fact s_chg.value --> false
  end
  context("Buffering signal history and SMA calculation") do
    # simple vector test case
    nsma = 10
    vval = rand(100)
    vsma = fill(NaN, 100)
    [vsma[i] = mean(vval[(i-nsma+1):i]) for i = 10:100]

    s_inp = Reactive.Input(vval[1])
    s_sma = Reactive.lift(mean, Reactive.foldl(
                            TradingLogic.sighistbuffer!,
                            TradingLogic.initbuff(nsma, s_inp.value),
                            s_inp))
    vsma_sig = Array(Float64, 100)
    vsma_sig[1] = s_sma.value
    for i = 2:100
      push!(s_inp, vval[i])
      vsma_sig[i] = s_sma.value
    end
    @fact all(isnan(vsma_sig[1:9])) --> true
    @fact vsma_sig[10:100] --> roughly(vsma[10:100])
  end
end
