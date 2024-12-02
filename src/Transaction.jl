module  Transaction

struct ArkTransaction
    id::Int
    receiver_id::Int
    timeout::Int64
    amount: Float64
end 

function Base.:+(a::ArkTransaction, b::ArkTransaction)
    return a.amount + b.amount
end

end