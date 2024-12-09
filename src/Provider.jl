module Provider
include("Transaction.jl")


using Agents ,Distributions, Random
using .Transaction: ArkTransaction


mutable struct ArkProvider
    current_liquidity::Float64
    round_lock_timeout::Int64
    spent_transactions:: Array{ArkTransaction}
    unspent_transactions:: Array{ArkTransaction}
    is_liquid::Bool
end


function update_provider!(provider::ArkProvider, new_spent_outputs::Array{ArkTransaction}, new_transferred_output::Array{ArkTransaction}, current_time::Int64)
    i = 1
    arrLength = length(provider.spent_transaction)
    while i <= arrLength
        transaction = get(provider.spent_transaction, i, nothing)
        if transaction.timeout >= current_time 
            provider.current_liquidity += transaction.amount;
            popat!(provider.spent_transaction, i)  # Remove the element at index `i`
        else
            i += 1  # Only increment if no element was removed
        end
    end

    left_over_liquidity = provider.current_liquidity - reduce!(+,new_transferred_output)
    if (left_over_liquidity > 0.0000_0546)
        provider.current_liquidity = left_over_liquidity
        push!(provider.unspent_transactions, new_transaction)
        append!(provider.spent_transactions, new_spent_outputs)
    else
        provider.is_liquid = false
    end
end

end