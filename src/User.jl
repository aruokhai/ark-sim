module User

using Agents ,Distributions, Random

# Step 1: Define the Bitcoin User Agent
mutable struct ArkUser <: AbstractAgent
    id::Int                 # Unique ID
    transaction_rate::Float64 # Probability of transacting
    transaction_value::String        # Behavior: "high", "medium", "low"
    total_amount_transfers::Float64
     #  TODO: reliability: Float64
end

# Step 2: Define Agent Behaviors
function user_behavior!(user, model)
    price = model.price
    transfer_amount = 0.0
    if rand(Bernoulli(user.transaction_rate)) == 0
        return 0
    end

    if user.transaction_value == "high"
        transfer_amount =  (rand(Uniform(0.01, 0.1)))/ price # Random trade amount
    elseif user.transaction_value == "medium"
        transfer_amount = (rand(Uniform(0.001, 0.01)))/ price
    elseif user.transaction_value == "low"
        transfer_amount = (rand(Uniform(0.0001, 0.001)))/ price
    end

    user.total_amount_transfers += transfer_amount
end

end # module end