using Random
using UUIDs

# Define the configuration structure
struct NetworkConfig
    num_users::Int           # Number of users
    provider_balance::Int64 # Initial balance of the provider
    provider_round_lock_timeout::Int64 # Round lock timeout of the provider in days
    users_balance_amount:: Int64 # Default transaction amount
    users_balance_timeout::Int # Default transaction time
    users_transaction_rate::Float64 # Transaction rate
    users_tier_proportion::Dict{String, Float64} # Transaction tier ratios
end

function initialize_network(config::NetworkConfig)
    users = ArkUser[]  # Initialize an empty array for users
    user_id = 1        # Initialize the user ID counter

    for (tier, ratio) in config.users_tier_proportion
        num_tier_users = round(Int, config.num_users * ratio)
        for _ in 1:num_tier_users
            push!(users, ArkUser(user_id, config.users_transaction_rate, tier))
            user_id += 1  # Increment the user ID
        end
    end

    transactions = Dict{UUID, ArkTransaction}()
    for i in 1:length(users)
        id = uuid1()
        transactions[id] = ArkTransaction(id, i, config.users_balance_timeout,config.users_balance_amount,  false, false) 
    end

    # Define model properties using configuration
    properties = Dict(:provider => ArkProvider(config.provider_balance, config.provider_round_lock_timeout, transactions, true),
        :current_time => 0,
        :failed_transactions => Int64[],
        :past_liquidity => config.provider_balance,
        :participating_agent => 0)

    # Define the model behavior
    function model_step!(model)
        model.current_time += 1
        model.failed_transactions = Int64[]
        model.past_liquidity = model.provider.current_liquidity
        model.participating_agent = 0
        println("round", model.current_time, "completed")
    end
    
    # Initialize the model
    model = StandardABM(
        ArkUser, 
        agent_step! = user_behavior!, 
        model_step! = model_step!,
        properties = properties, 
        scheduler = Schedulers.Randomly()
    )
    
    # Add users to the model
    for agent in users
        add_agent!(agent, model)
    end
    
    return model
end



function run_network(config::NetworkConfig, steps::Int)

    mdata = [(:failed_transactions), (:past_liquidity), (:participating_agent)]
    model = initialize_network(config)  # Create a network 
    return run!(model, steps; mdata)           # Simulate 
    
end