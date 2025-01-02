using Random
using UUIDs
using Base.Threads
using Agents
using DataFrames

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
    df = DataFrame(time=Int[], failed_transactions= Vector{Int}[], past_liquidity=Int64[], participating_agent=Int[])  # Define column types

    for (tier, ratio) in config.users_tier_proportion
        num_tier_users = round(Int, config.num_users * ratio)
        for _ in 1:num_tier_users
            push!(users, ArkUser(user_id, config.users_transaction_rate, tier))
            user_id += 1  # Increment the user ID
        end
    end

    transactions = Dict{UUID, ArkTransaction}()
    agents_vtxos = Dict{Int, Set{UUID}}()

    for i in 1:length(users)
        id = uuid1()
        transactions[id] = ArkTransaction(id, i, config.users_balance_timeout,config.users_balance_amount,  false)
        agents_vtxos[i] = Set([id]); 
    end
    

    # Define model properties using configuration
    properties = Dict(:provider => ArkProvider(config.provider_balance, config.provider_round_lock_timeout, transactions,agents_vtxos,[], true),
        :current_time => 0,
        :failed_transactions => Int64[],
        :df => df,
        )

    # Define the model behavior
    function model_step!(model)

        chunks = Iterators.partition(allagents(model), floor(Int,length(allagents(model)) ÷ Threads.nthreads()))
        Threads.@threads for chunk in collect(chunks)
            for agent in chunk
                receiver_agent = random_agent(model)
                user_behavior!(agent, model, receiver_agent)
            end
        end 

        push!(model.df, (model.current_time, model.failed_transactions, model.provider.current_liquidity,  length(model.provider.round_agents)))

        model.current_time += 1
        model.failed_transactions = Int64[]
        model.provider.round_agents = Int[]

        # Remove all spent_transactions whose timeout is >= current_time.
        for utxo in values(model.provider.transactions)
            if utxo.timeout <= model.current_time
                model.provider.current_liquidity += utxo.amount
                delete!(model.provider.transactions, utxo.id)
                delete!(model.provider.agents_vtxos[utxo.receiver_id], utxo.id)
            end
        end

        
        println("round", model.current_time, "completed")
    end
    
    # Initialize the model
    model = StandardABM(
        ArkUser, 
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
    model = initialize_network(config)  # Create a network 
    run!(model, steps)
    return model.df           # Simulate 
    
end