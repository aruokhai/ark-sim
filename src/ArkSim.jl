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
        # Txrate: 0.000013657/minute = 0.59/month, 10% high, 60% medium, 30% low, avg balance 1000 usd, 5000 user, initial amount of 1btc, round is 1 minute, timout is 30 days = 43,200 minutes
        # run simulation for 1 year
        # visa_network = NetworkConfig(500_000, 100_000_000_000, 43_200, 1_000_000, 43_200, 0.000013657, Dict("high" => 0.1, "medium" => 0.6, "low" => 0.3))
        # adata, mdata = run_network(visa_network, 518400)
        visa_network = NetworkConfig(200, 100_000_000_000, 43_200, 1_000_000, 43_200, 0.59, Dict("high" => 0.1, "medium" => 0.6, "low" => 0.3))
        adata, mdata = run_network(visa_network, 5)
        CSV.write("data.csv", mdata; bufsize=10^9)
    end

    main()

end # module ArkSim
