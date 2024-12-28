using Agents ,Distributions, Random

mutable struct ArkProvider
    current_liquidity::Int64 # amount in satoshis controled by the provider
    round_lock_timeout::Int64 # timeout for the current round in days, after which the provider can withdraw the liquidity 
    transactions:: Dict{UUID, ArkTransaction} # vtxos that are transferred
    is_liquid::Bool
end

function update_provider!(
    provider::ArkProvider,
    new_transactions::Array{ArkTransaction},
    spent_utxos::Array{ArkTransaction},
    current_time::Int
)
    # Remove all spent_transactions whose timeout is >= current_time.
    for utxo in values(provider.transactions)
        if utxo.timeout <= current_time
            provider.current_liquidity += utxo.amount
            delete!(provider.transactions, utxo.id)
        end
    end

    # Sum the amount field of new transferred outputs
    transferred_amount = sum(tx -> tx.amount, new_transactions)
    left_over_liquidity = provider.current_liquidity - transferred_amount

    # Dust Limit in satoshis
    MIN_LIQUIDITY_THRESHOLD = 546

    if left_over_liquidity > MIN_LIQUIDITY_THRESHOLD
        # Check if all the spent UTXOs are available
        for utxo in spent_utxos
            if !haskey(provider.transactions, utxo.id)
                println("Error: Provider does not have all the spent UTXOs")
                return nothing
            end
        end

        # Mark the spent UTXOs as spent
        for utxo in spent_utxos
            provider.transactions[utxo.id].isSpent = true
        end
        
        # Update provider’s liquidity
        provider.current_liquidity = left_over_liquidity

        # Add the new transferred outputs to unspent
        for new_transactions in new_transactions
            provider.transactions[new_transactions.id] = new_transactions
        end
    else
        # Mark the provider as illiquid
        provider.is_liquid = false
    end
end


