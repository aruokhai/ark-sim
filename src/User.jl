import  Agents: AbstractAgent, ran 
import Distributions: Uniform, Bernoulli 
import Random: rand
import UUIDs: uuid4, UUID
using Base.Threads

# Create a ReentrantLock
l = ReentrantLock()


const SATOSHIS_PER_BTC = 100_000_000
const DUST_LIMIT_SATS = 546  # Typical minimum dust threshold in satoshis

# Step 1: Define the Bitcoin User Agent
mutable struct ArkUser <: AbstractAgent
    id::Int                 # Unique ID
    transaction_rate::Float64 # Probability of transacting
    transaction_value::String  # Behavior: "high", "medium", "low"
end


function user_behavior!(user, model)
    provider::ArkProvider = model.provider
    current_time = model.current_time
    failed_transactions = model.failed_transactions

    # Decide if the user transacts this time step
    # rand() returns a uniform float in [0,1), so compare to transaction_rate
    if rand() > user.transaction_rate
        return
    end

    # Compute transfer_amount in satoshis based on user's transaction_value
    transfer_amount = rand_transfer_amount(user.transaction_value)
    user_utxos = get_user_utxos(user, provider)

    if (length(user_utxos) == 0)
        return
    end

    # Calculate how much balance remains after proposed transfer
    balance = sum(utxo -> utxo.amount, user_utxos)

    amount_remaining = balance - transfer_amount

    # If the remaining balance is below dust threshold, skip transaction
    if amount_remaining <= DUST_LIMIT_SATS
        return
    end

    # Select coins to spend using a greedy algorithm
    spent_utxos, _, change_amount = select_coins_greedy(user_utxos, transfer_amount)

    # Pick a random agent to send funds to

    returned_random_agent = random_agent(model)

    # Construct transactions: change back to self, and the actual transfer
    transfer_transaction = ArkTransaction(uuid4(), returned_random_agent.id, current_time + 10, transfer_amount, false)
    new_transactions = [transfer_transaction]    

    # Only add a change transaction if change_amount is positive
    if change_amount > 0
        change_transaction = ArkTransaction(uuid4(), user.id, current_time + 10, change_amount, false)
        push!(new_transactions, change_transaction)
    end

    lock(l) do 
        # Update the provider with spent UTXOs & newly created transactions
        update_provider!(provider, new_transactions,spent_utxos, failed_transactions, user.id) 
    end

end

"""
    rand_transfer_amount(tier::String) -> Int

Generate a random transfer amount (in satoshis) based on the user's transaction tier:
"high", "medium", or "low".
"""
function rand_transfer_amount(tier::String)::Int
    if tier == "high"
        # Range: 0.01 BTC to 0.1 BTC, converted to satoshis
        return round(Int, rand(Uniform(0.005, 0.01)) * SATOSHIS_PER_BTC)
    elseif tier == "medium"
        return round(Int, rand(Uniform(0.001, 0.005)) * SATOSHIS_PER_BTC)
    elseif tier == "low"
        return round(Int, rand(Uniform(0.0005, 0.001)) * SATOSHIS_PER_BTC)
    else
        # Default fallback or throw an error if tier is unknown
        error("Unknown transaction_value tier: $tier")
    end
end

function get_user_utxos(user::ArkUser, provider::ArkProvider)::Array{ArkTransaction}
    user_utxos_ids = get(provider.agents_vtxos, user.id, Set([]))
    return [provider.transactions[utxo_id] for utxo_id in user_utxos_ids]
end

"""
    select_coins_greedy(utxos::Dict{UUID, ArkTransaction}, target::Int64) -> Tuple{Array{ArkTransaction}, Int64, Int64}

"""

function select_coins_greedy(utxos::Array{ArkTransaction}, target::Int64) 
    # Sort coins in descending order by amount
    sorted_coins = sort(utxos, by = c -> c.amount, rev = true)

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
