__precompile__(true)

module ArkSim
    # Re-export them from the top-level ArkSim module
    include("Transaction.jl")
    include("Provider.jl")
    include("User.jl")
    include("Network.jl")
    
    export main

    function main()
        visa_network = NetworkConfig(5, 10_00_000_000, 30, 530_000, 10, 0.59, Dict("high" => 0.1, "medium" => 0.6, "low" => 0.3))
        run_network(visa_network, 5)
        println("Simulation completed")
    end

    main()

end # module ArkSim
