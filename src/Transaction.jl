using UUIDs
mutable struct ArkTransaction
    id::UUID
    receiver_id::Int
    timeout::Int64
    amount::Int64
    isSpent::Bool
    isForfeited::Bool
end 


function Base.:+(a::ArkTransaction, b::ArkTransaction)
    return a.amount + b.amount
end
