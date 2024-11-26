module User

using Agents

# Step 1: Define the Bitcoin User Agent
struct BitcoinUser <: AbstractAgent
    id::Int                 # Unique ID
    balance::Float64        # Wallet balance (in BTC)
    transaction_rate::Float64 # Probability of transacting
    strategy::String        # Behavior: "holder", "trader", "miner"
end

# Step 2: Define Agent Behaviors
function user_behavior!(user, network)
    if user.strategy == "trader"
        # Simulate trading: buy/sell based on Bitcoin price
        price = network[:price]
        trade_amount = rand(Uniform(0.01, 0.1)) # Random trade amount
        if rand() > 0.5
            user.balance += trade_amount / price  # Buy BTC
        else
            user.balance -= trade_amount / price  # Sell BTC
        end
    elseif user.strategy == "miner"
        # Simulate mining: small chance of earning rewards
        reward = 6.25  # Current BTC block reward
        if rand() < 0.001
            user.balance += reward
        end
    end
end

end # module end