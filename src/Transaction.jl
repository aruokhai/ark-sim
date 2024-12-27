mutable struct ArkTransaction
    id::Int
    receiver_id::Int
    timeout::Int64
    amount::Int64
    isClaimed::Bool
end 


function Base.:+(a::ArkTransaction, b::ArkTransaction)
    return a.amount + b.amount
end
