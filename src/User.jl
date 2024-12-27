import  Agents: AbstractAgent 
import Distributions: Uniform, Bernoulli 
import Random: rand 

const SATOSHIS_PER_BTC = 100_000_000
const DUST_LIMIT_SATS = 546  # Typical minimum dust threshold in satoshis

# Step 1: Define the Bitcoin User Agent
mutable struct ArkUser <: AbstractAgent
    id::Int                 # Unique ID
    transaction_rate::Float64 # Probability of transacting
    transaction_value::String        # Behavior: "high", "medium", "low"
    utxos::Dict{Int64, ArkTransaction}
     #  TODO: reliability: Float64
end


function user_behavior!(user, model)
    provider::ArkProvider = model.provider
    current_time = model.current_time

    # Decide if the user transacts this time step
    # rand() returns a uniform float in [0,1), so compare to transaction_rate
    if rand() > user.transaction_rate
        return
    end

    # Compute transfer_amount in satoshis based on user's transaction_value
    transfer_amount = rand_transfer_amount(user.transaction_value)

    # Pull in newly discovered UTXOs from provider that belong to this user
    i = 1;
    for utxo in provider.transactions
        if !utxo.isClaimed && utxo.receiver_id == user.id
            user.utxos[utxo.id] = utxo
            println("User ", user.id, " found UTXO ", utxo.id)
            model.provider.transactions[i].isClaimed = true
        end
        i += 1
    end

    # Calculate how much balance remains after proposed transfer
    amount_remaining = sum(utxo -> utxo.amount, values(user.utxos)) - transfer_amount

    # If the remaining balance is below dust threshold, skip transaction
    if amount_remaining <= DUST_LIMIT_SATS
        return
    end

    # Select coins to spend using a greedy algorithm
    spent_utxos, _, change_amount = select_coins_greedy(user.utxos, transfer_amount)
    println("User ", user.id, " selected UTXOs to spend: ", spent_utxos, "spent_amount: ", transfer_amount, "change_amount: ", change_amount)   

    # Remove the spent UTXOs from user's UTXO set
    for utxo in spent_utxos
        println("User ", user.id, " spent UTXO ", utxo.id)
        delete!(user.utxos, utxo.id)
    end

    # Pick a random agent to send funds to
    random_agent = rand(model.agents)

    # Construct transactions: change back to self, and the actual transfer
    transfer_transaction = ArkTransaction(rand(1:100000), random_agent.id, current_time + 10, transfer_amount, false)
    new_transactions = [transfer_transaction]    

    # Only add a change transaction if change_amount is positive
    if change_amount > 0
        change_transaction = ArkTransaction(rand(1:100000), user.id, current_time + 10, change_amount, true)
        println("User ", user.id, " received change UTXO ", change_transaction.id)
        user.utxos[change_transaction.id] = change_transaction
        push!(new_transactions, change_transaction)
    end

    # Update the provider with spent UTXOs & newly created transactions
    update_provider!(provider, new_transactions, current_time)
end

"""
    rand_transfer_amount(tier::String) -> Int

Generate a random transfer amount (in satoshis) based on the user's transaction tier:
"high", "medium", or "low".
"""
function rand_transfer_amount(tier::String)::Int
    if tier == "high"
        # Range: 0.01 BTC to 0.1 BTC, converted to satoshis
        return round(Int, rand(Uniform(0.01, 0.1)) * SATOSHIS_PER_BTC)
    elseif tier == "medium"
        return round(Int, rand(Uniform(0.001, 0.01)) * SATOSHIS_PER_BTC)
    elseif tier == "low"
        return round(Int, rand(Uniform(0.0001, 0.001)) * SATOSHIS_PER_BTC)
    else
        # Default fallback or throw an error if tier is unknown
        error("Unknown transaction_value tier: $tier")
    end
end




function select_coins_greedy(utxos::Dict{Int, ArkTransaction}, target::Int64)
    # Convert the dictionary values to a vector
    coin_list = collect(values(utxos))
    
    # Sort coins in descending order by amount
    sorted_coins = sort(coin_list, by = c -> c.amount, rev = true)

    # Initialize selected coins array
    selected = ArkTransaction[]

    total = 0
    for utxo in sorted_coins
        if total >= target
            break
        end
        push!(selected, utxo)
        total += utxo.amount
    end

    change_amount = total - target
    return selected, total, change_amount
end 
