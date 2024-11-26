module ArkSim
include("User.jl")

using Agents, Distributions, Random, Plots
import .User: BitcoinUser, user_behavior!


function initialize_network(num_users)
    users = [BitcoinUser(i, rand(Uniform(0, 1)), rand(Uniform(0.01, 0.1)), 
                        rand(["holder", "trader", "miner"])) for i in 1:num_users]
    properties = Dict(:price => 50000.0)  # Initial Bitcoin price
    return Agents.ABM(BitcoinUser, Agents.SimpleSpace(), properties, users)
end

# Step 4: Simulate the Model
function simulate!(model, steps)
    for step in 1:steps
        model[:price] *= 1 + rand(Normal(0, 0.01))  # Simulate price volatility
        step!(model, user_behavior!)
    end
end

# Step 5: Analyze Results
function analyze_model(model)
    balances = [agent.balance for agent in model.agents]
    println("Average balance: ", mean(balances))
    histogram(balances, bins=20, title="Distribution of Bitcoin Balances", xlabel="BTC", ylabel="Frequency")
end

# Main Script
function run_simulation()
    model = initialize_network(100)  # Create a network with 100 users
    simulate!(model, 100)            # Simulate 100 time steps
    analyze_model(model)
    println("hello world")
end


end # module ArkSim
