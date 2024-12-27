#=  test_user.jl  =#

using Test
using Random: seed!

include("../src/ArkSim.jl")
using .ArkSim: ArkUser, ArkTransaction, ArkProvider, user_behavior!, select_coins_greedy,BTC



# We'll define a mock model type for testing user_behavior! 
mutable struct MockModel
    provider::ArkProvider
    agents::Vector{ArkUser}
    current_time::Int64
end

@testset "ArkUser tests" begin

    @testset "ArkUser Instantiation" begin
        # Create an ArkUser
        user = ArkUser(1, 0.5, "medium", Dict{Int64, ArkTransaction}())

        @test user.id == 1
        @test user.transaction_rate == 0.5
        @test user.transaction_value == "medium"
        @test user.utxos == Dict{Int64, ArkTransaction}()
    end


    @testset "select_coins_greedy tests" begin
        # Build some ArkTransactions for testing
        tx1 = ArkTransaction(1, 2, 0, 1, false)   # from user 1 to user 2
        tx2 = ArkTransaction(1, 2, 0, 5, false)
        tx3 = ArkTransaction(1, 2, 0, 2, false)

        # Insert these transactions in a dictionary keyed by transaction id
        utxos = Dict(
            1 => tx1,
            2 => tx2,
            3 => tx3
        )

        @testset "Exact match test" begin
            target_amount = 5
            selected, total, change = select_coins_greedy(utxos, target_amount)

            @test length(selected) == 1
            @test total == 5
            @test change == 0
        end

        @testset "Greedy accumulation test" begin
            # Request an amount that forces multiple coins to be used
            target_amount = 7 
            selected, total, change = select_coins_greedy(utxos, target_amount)

            @test length(selected) == 2  # Should pick tx2(5) + tx1(2)
            @test total == 7
            @test change == 0
        end

        @testset "Change is returned test" begin
            target_amount = 6
            selected, total, change = select_coins_greedy(utxos, target_amount)

            # Should pick tx1 (0.01) for the smallest coin that meets the target
            @test length(selected) == 2
            @test total == 7
            @test change == 1
        end

        @testset "No selection needed test" begin
            # If target is zero or extremely small, we might expect either no coins
            target_amount = 0
            selected, total, change = select_coins_greedy(utxos, target_amount)

            # Even though the code as written doesn't explicitly handle zero-target,
            # let's see how it behaves
            # Possibly it won't pick anything if total >= target is trivially satisfied at 0
            @test length(selected) == 0
            @test total == 0
            @test change == 0
        end
    end


    @testset "user_behavior! tests" begin
        # We create a user, a provider, and a model. 
        # Then we test user_behavior! in different scenarios.

        # 1) Build a user with some typical initial state
        user = ArkUser(10,1.0,"low", Dict{Int64, ArkTransaction}())

        # 2) Create some unspent transactions in the provider that belong to user
        u_tx1 = ArkTransaction(10, 10, 20, 15_000_000, false)  # user is both sender/receiver
        u_tx2 = ArkTransaction(11, 10, 20, 20_000_000, false)
        provider = ArkProvider(100_000_000, 10,[u_tx1, u_tx2], true)
        
        # 3) Build a model 
        user2 = ArkUser(20, 1.0, "medium", Dict{Int64, ArkTransaction}()
        )
        agents = [user, user2]
        model = MockModel(provider, agents, 0)

        @testset "Low value transaction behavior" begin
            # We'll fix the RNG seed for reproducibility
            seed!(1234)

            @test user_behavior!(user, model) !== nothing
            # After user_behavior!, user’s UTXOs should be updated:
            #   - The user sees the new unspent UTXOs from the provider (u_tx1, u_tx2)
            #   - Then user spends some coins, leading to new transactions
            # Check that user now has *some* entries in utxos
            @test !isempty(user.utxos)

            # In the provider, the spent transactions are removed from unspent
            # and replaced with new ones (change + transfer).
            @test length(user.utxos) == 2
            @test length(provider.transactions) == 4  # spent 2, added 2 again
            @test provider.current_liquidity == 80_000_000
        end


        # @testset "User can't spend if not enough balance" begin
        #     # Reset user UTXOs and provider unspent to minimal
        #     user.utxos = Dict{Int64, ArkTransaction}()
        #     provider.unspent_transactions = [ArkTransaction(10, 10, 0, 544)]  # 544
        #     provider.mempool = []

        #     # Make sure user’s behavior doesn’t proceed with a spend if low
        #     @test user_behavior!(user, model) === nothing
        #     # Because the transaction_value is "low", but even that might exceed
        #     # the threshold (≥ 546). So no new transactions are created.
        #     @test isempty(provider.mempool)
        # end


        # @testset "Transaction rate = 0 means user never transacts" begin
        #     # Temporarily create a new user with rate 0
        #     nonspender = ArkUser(
        #         id=30,
        #         transaction_rate=0.0,
        #         transaction_value="high",
        #         utxos=Dict{Int64, ArkTransaction}()
        #     )
        #     push!(model.agents, nonspender)

        #     # Add some UTXOs so that if the user did spend, it would appear in mempool
        #     provider.unspent_transactions = [ArkTransaction(30, 30, 0, 0.05)]
        #     @test user_behavior!(nonspender, model) === nothing
        #     @test isempty(provider.mempool)
        # end
    end
end
