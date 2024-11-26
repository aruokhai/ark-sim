module Main
include("src/ArkSim.jl")

import .ArkSim: run_simulation

# Main Script
function main()
    run_simulation()
end

main()

end # module ArkSim
