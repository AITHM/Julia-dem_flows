using Test
using demographic_flows_jl 
#A fixed value test to check how that the dem flows function works

@testset "demography_rates_proportional" begin
    all_states = [
    0.0437 0.0073 0
    0.0246 0.0073 0.0073
    0.0314 0.0073 0.00730
    0.0770 0.0073 0.0073
    0 0.0219 0.0437]
    tvec = [ 1., 10., 100. ]
    initial_state = [ 0.1199, 0.0684, 0.0173, 0.0187, 0]
    drates = demography_rates_proportional(tvec, all_states, false)
    correct_drates = [[-0.1988 0 0 0 0
    0 -0.1350 0 0 0
    0 0 -0.1621 0 0
    0 0 0 -0.2618 0
    0.0302 0.0302 0.0302 0.0302 0],
    [-0.0768 0 0 0 0
    0 0 0 0 0
    0 0 0 0 0
    0 0 0 0 0
    0 0 0 0 0.0077]]
    @test all(isapprox.(drates[:,:,1], correct_drates[1], atol=0.0001))
    @test all(isapprox.(drates[:,:,2], correct_drates[2], atol=0.0001))
end

#Based on Emmas original testing
@testset "model" begin
    state1 = rand(5, 1) ./ 8
    state1[5] = 0
    state2 = state1 ./ 6
    state2[2:5]= state2[1] .* [1,1,1,3]
    state3 = state2
    state3[1]= 0
    state3[5] *= 2
    tvec=[1. 10. 100.]
    all_states = zeros(length(state1), length(tvec))
    all_states[:, 1] = state1;
    all_states[:, 2] = state2;
    all_states[:, 3] = state3;
    demographic_flows = demography_rates_proportional(tvec, all_states)
    y_state = return_epi(tvec, demographic_flows, state1, tvec)
    ages_and_vacc_at_start = y_state[:, 1]
    @test all(isapprox.(ages_and_vacc_at_start, state1, atol=0.0001))
    ages_and_vacc_at_10 = y_state[:, 2]
    @test all(isapprox.(ages_and_vacc_at_10, state2, atol=0.0001))
    ages_and_vacc_at_100 = y_state[:, 3]
    @test all(isapprox.(ages_and_vacc_at_100, state3, atol=0.0001))
end
