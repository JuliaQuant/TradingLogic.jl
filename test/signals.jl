facts("Working with signals") do
  context("Change detection") do
    s_inp = Reactive.Input(5)
    s_chg = TradingLogic.schange(s_inp)
    push!(s_inp, 5)
    @fact s_chg.value => false
    push!(s_inp, 8)
    @fact s_chg.value => true
    push!(s_inp, 8)
    @fact s_chg.value => false
  end
end
