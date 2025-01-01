using Agents ,Distributions, Random

mutable struct ArkProvider
    current_liquidity::Int64 # amount in satoshis controled by the provider
    round_lock_timeout::Int64 # timeout for the current round in days, after which the provider can withdraw the liquidity 
    transactions:: Dict{UUID, ArkTransaction} # vtxos that are transferred
    agents_vtxos:: Dict{Int, Set{UUID}} # vtxos that are owned by agents
    round_agents:: Array{Int}
    is_liquid::Bool
end

function update_provider!(
    provider::ArkProvider,
    new_transactions::Array{ArkTransaction},
    spent_utxos::Array{ArkTransaction},
    failed_transactions::Array{Int64},
    sender_id::Int
)
    
    # Sum the amount field of new transferred outputs
    transferred_amount = sum(tx -> tx.amount, new_transactions)
    left_over_liquidity = provider.current_liquidity - transferred_amount

    # Dust Limit in satoshis
    MIN_LIQUIDITY_THRESHOLD = 546

    if left_over_liquidity > MIN_LIQUIDITY_THRESHOLD
        # Check if all the spent UTXOs are available
        for utxo in spent_utxos
            if !haskey(provider.transactions, utxo.id)
                return nothing
            end
        end

        # Mark the spent UTXOs as spent
        for utxo in spent_utxos
            provider.transactions[utxo.id].isSpent = true
        end
        
        # Update provider’s liquidity
        provider.current_liquidity = left_over_liquidity

        # append the sender_id to the list of round agents
        push!(provider.round_agents, sender_id)

        # Add the new transferred outputs to unspent
        for new_transactions in new_transactions
            provider.transactions[new_transactions.id] = new_transactions
            push!(provider.agents_vtxos[new_transactions.receiver_id], new_transactions.id)
        end
    else
        # Mark the provider as illiquid
        append!(failed_transactions, map(tx -> tx.amount, new_transactions ) )
    end
end


