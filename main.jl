module Main
include("src/ArkSim.jl")

using .ArkSim: run_simulation

# Main Script
function main()
    run_simulation()
end

main()

end # module ArkSim
