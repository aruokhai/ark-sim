module ArkSim
include("User.jl")

using Agents, Distributions, Random, Plots
import .User: ArkUser, user_behavior!

gr()

function initialize_network(num_users)
    users = [ArkUser(i, rand(Uniform(0, 1)), rand(["high", "medium", "low"]), 0.0) for i in 1:num_users]
    properties = Dict(:price => 93402.0)  # Initial Bitcoin price
    model =  StandardABM(ArkUser, agent_step! = user_behavior!, properties = properties, scheduler = Schedulers.Randomly())
    for agent in users
        add_agent!(agent, model)
    end
    return model

end

# Step 4: Simulate the Model
function simulate!(model)
    scheduler1 = Schedulers.Randomly()
    for id in scheduler1(model)
        user_behavior!(model[id], model)
    end

    # for _ in 1:steps
    #     # model[:price] *= 1 + rand(Normal(0, 0.01))  # Simulate price volatility
    #     step!(model, user_behavior!)
    # end
end

# Step 5: Analyze Results
function analyze_model(adata)
    display(bar(adata.id, adata.total_amount_transfers, xlabel="User Is", ylabel="Amount Transfered",  title="Distribution of Amount Transfered"))
end

# Main Script
function run_simulation()
    model = initialize_network(100)  # Create a network with 100 users
    adata = [(:total_amount_transfers)]
    adf, mdf = run!(model,100; adata)            # Simulate 100 time steps
    modified_adf = adf[adf.time .== 100, :]
    println(modified_adf);
    analyze_model(modified_adf)
end


end # module ArkSim
