__precompile__(true)

module ArkSim
    # Re-export them from the top-level ArkSim module
    include("Transaction.jl")
    include("Provider.jl")
    include("User.jl")
    
    
    

    
    

# using Agents, Distributions, Random, Plots
# using ..User: ArkUser, user_behavior!
# using ..Provider: ArkProvider, update_provider!
# using ..Transaction: ArkTransaction

# gr()

# function initialize_network(num_users)
#     users = [ArkUser(i, rand(Uniform(0, 1)), rand(["high", "medium", "low"]), Dict(1 => ArkTransaction(1, i, 5, 10.0))) for i in 1:num_users]
#     properties = Dict(:provider => ArkProvider(100, 10, [],[], true))
#     model =  StandardABM(ArkUser, agent_step! = user_behavior!, properties = properties, scheduler = Schedulers.Randomly())
#     for agent in users
#         add_agent!(agent, model)
#     end
#     return model

# end


# # function analyze_model(adata)
# #     display(bar(adata.id, adata.total_amount_transfers, xlabel="User Is", ylabel="Amount Transfered",  title="Distribution of Amount Transfered"))
# # end

# # Main Script
# function run_simulation()
#     model = initialize_network(100)  # Create a network with 100 users
#     # adata = [(:total_amount_transfers)]
#     # adf, mdf = run!(model,100; adata) 
#     run!(model,100)           # Simulate 100 time steps
#     # modified_adf = adf[adf.time .== 100, :]
#     # println(modified_adf);
#     # analyze_model(modified_adf)
# end


end # module ArkSim
