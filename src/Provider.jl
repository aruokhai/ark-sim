using Agents ,Distributions, Random

mutable struct ArkProvider
    current_liquidity::Int64
    round_lock_timeout::Int64
    transactions:: Array{ArkTransaction}
    is_liquid::Bool
end

function update_provider!(
    provider::ArkProvider,
    new_transactions::Array{ArkTransaction},
    current_time::Int
)
    # Remove all spent_transactions whose timeout is >= current_time.
    # (If the logic is reversed, adjust accordingly.)
    i = 1
    while i <= length(provider.transactions)
        transaction = provider.transactions[i]
        if transaction.timeout <= current_time
            provider.current_liquidity += transaction.amount
            popat!(provider.transactions, i)  
            # or deleteat!(provider.spent_transactions, i) if you prefer Base Julia
        else
            i += 1
        end
    end

    # Sum the amount field of new transferred outputs
    transferred_amount = sum(tx -> tx.amount, new_transactions)
    left_over_liquidity = provider.current_liquidity - transferred_amount

    # Define a named threshold for clarity
    MIN_LIQUIDITY_THRESHOLD = 546

    if left_over_liquidity > MIN_LIQUIDITY_THRESHOLD
        # Update provider’s liquidity
        provider.current_liquidity = left_over_liquidity

        # Add the new transferred outputs to unspent
        # (If it’s supposed to be just one new transaction, adjust accordingly.)
        append!(provider.transactions, new_transactions)
    else
        # Mark the provider as illiquid
        provider.is_liquid = false
    end
end


