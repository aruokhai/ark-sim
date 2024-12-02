module User
include("Transaction.jl")
include("Provider.jl")

using Agents ,Distributions, Random
using .Transaction: ArkTransaction
using .Provider: update_provider!


# Step 1: Define the Bitcoin User Agent
mutable struct ArkUser <: AbstractAgent
    id::Int                 # Unique ID
    transaction_rate::Float64 # Probability of transacting
    transaction_value::String        # Behavior: "high", "medium", "low"
    utxos::Dict{Int, ArkTransaction}
    amount_remaining::Float64
     #  TODO: reliability: Float64
end

# Step 2: Define Agent Behaviors
function user_behavior!(user, model)
    provider = model.provider
    current_time = model.current_time
    transfer_amount = 0.0
    if rand(Bernoulli(user.transaction_rate)) == 0
        return
    end

    if user.transaction_value == "high"
        transfer_amount =  (rand(Uniform(0.01, 0.1)))
    elseif user.transaction_value == "medium"
        transfer_amount = (rand(Uniform(0.001, 0.01)))
    elseif user.transaction_value == "low"
        transfer_amount = (rand(Uniform(0.0001, 0.001)))
    end
 
    amount_remaining = user.amount_remaining - transfer_amount
    if amount_remaining < 0.00000000
        return
    end

    spent_utxos, total = select_coins_greedy(user.utxos, transfer_amount)

    for utxo in spent_utxos
        delete!(user.utxos, utxo.id)
    end

    user.amount_remaining = amount_remaining
    change_amount = total - transfer_amount

    user.total_amount_transfers += transfer_amount
    random_agent = rand(model.agents);
    change_transaction = ArkTransaction(random_agent.id, user.id, current_time + 10, change_amount)
    transfer_transaction = ArkTransaction(random_agent.id, user.id, current_time + 10, transfer_amount)

    update_provider!(provider, spent_utxos, [change_transaction, transfer_transaction], current_time)


end


function select_coins_greedy(utxos::Dict{Int, ArkTransaction}, target::Float64)
    selected::Array{ArkTransaction} = []
    total = 0.0
    
    # TODO: Sort coins in descending order
    # sorted_coins = sort(coins, rev=true)
    
    for utxo in utxos.values()
        if total >= target
            break
        end
        push!(selected, utxo)
        total += utxo.amount
    end

    return selected, total
end 

end # module end