__precompile__(true)

module ArkSim
    # Re-export them from the top-level ArkSim module
    include("Transaction.jl")
    include("Provider.jl")
    include("User.jl")
    include("Network.jl")

    using CSV

    export main

    function main()
        visa_network = NetworkConfig(5, 100_000_000_000, 30, 1_000_000, 10, 0.59, Dict("high" => 0.1, "medium" => 0.6, "low" => 0.3))
        adata = [(:total_amount_transfers)]
        adata, mdata = run_network(visa_network, 5)
        println("Simulation completed", mdata.provider)
        CSV.write("data.csv", mdata; bufsize=10^9)
    end

    main()

end # module ArkSim
