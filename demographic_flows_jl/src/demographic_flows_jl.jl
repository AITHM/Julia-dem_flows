module demographic_flows_jl
export demography_rates_proportional, return_epi
using Pkg.Artifacts
rootpath = artifact"dem_flows"
dem_flows_location = joinpath(rootpath, "CrossPlatformDemFlows")

function demography_rates_proportional(time_points, states_at_time_points, cversion = true)
    int(x) = floor(Int, x)
    dimx = length(time_points) - 1;
    state_at_points_flat = vcat(states_at_time_points')
    dimy = int(length(state_at_points_flat) / (dimx + 1));
    dimz = dimy;
    result = zeros(dimy, dimz, dimx);
    ccall(("demography_rates_proportional6", dem_flows_location),
    Cvoid,
    (Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble},Int32,Int32,Int32), 
    result, time_points, state_at_points_flat, dimx,  dimy, dimz);
    if cversion
        return result;
    else
        return permutedims(result, [2,1,3])
    end
end

function return_epi(times_step_changes, flows_demographic, initial_state, times)
    size_flows = size(flows_demographic)
    y_states = zeros(length(initial_state), length(times))
    dimx = size_flows[3];
    dimy = length(initial_state);
    dimz = length(initial_state);
    ccall(("return_epi", dem_flows_location),
    Cvoid, 
    (Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble},  Ptr{Cdouble}, Ptr{Cdouble}, Int32, Int32, Int32, Int32),
    y_states, times, times_step_changes, flows_demographic, initial_state, dimx, dimy, dimz, length(times))
    return y_states
end

end # module