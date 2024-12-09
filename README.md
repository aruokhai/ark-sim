# About ArkSim 

ArmSim is a _Liquidity Agent-Based Simulator_ designed to simulate the __Ark Protocol's__ liquidity requirements for operating an Ark Server effectively. The simulator aims to provide a robust framework for replicating real-world payment systems, enabling accurate modeling and analysis of the liquidity needs for seamless payment processing.

ArmSim focuses on maintaining simplicity while ensuring a high level of realism, requiring only the essential configurations necessary for real-world payment simulations. By replicating real-life scenarios, it provides valuable insights into liquidity dynamics, enabling operators to optimize Ark Protocol deployments under varying conditions.

## Key features of ArmSim

- __Realistic Payment Simulations__: Models user behavior, transaction flows, and liquidity demand in real-world-like payment systems.
- __Ark Protocol Focused__: Tailored specifically to simulate the unique requirements of the Ark Protocol's liquidity management.
- __Simplified Setup__: Designed to minimize setup complexity while maximizing simulation accuracy.


## Structure Of Project 

- __ArkSim.jl__: This is the Orchestrator, tasked with initializing and overseeing the operation of the Simulation System.

- __Provider.jl__: This is the Ark Server, the primary entity being analyzed in the simulation.

- __User.jl__: These are the Agent-Based Users of the system, modeled to closely resemble real-life behavior and interactions.




# How to Run

 Follow these steps to ensure you have everything configured correctly.


## Prerequisites

Before running the project, ensure you have the following installed:

1. **Julia**: Download and install Julia from [Julia's official website](https://julialang.org/downloads/).
2. **Git**: Install Git if you need to clone the project repository.


## Getting Started

### Step 1: Clone the Repository

If the project is hosted in a version control system like GitHub or GitLab, clone it using:

```bash
git clone git@github.com:aruokhai/ark-sim.git
cd arksim
```

### Step 2: Launch Julia

Navigate to the project directory and start the Julia REPL by typing:

```bash
julia
```

### Step 3: Activate the Project Environment

Activate the project's environment by running the following commands in the Julia REPL:

```julia
using Pkg
Pkg.activate(".")
```

### Step 4: Install Dependencies

To install all the required packages for the project, run:

```julia
Pkg.instantiate()
```

---

## Running the Project

### Typical Usage

After setting up the environment, you can run the main script or entry point of the project. For example:

```julia
include("main.jl")
```

### Using Command Line

Alternatively, you can run the project directly from the command line:

```bash
julia --project=. main.jl
```

---

## Testing the Project

run tests:

```julia
using Pkg
Pkg.test()
```

---

## Troubleshooting

1. **Missing Dependencies**: Ensure that `Project.toml` and `Manifest.toml` are present in the project directory. If dependencies are still missing, try running:
   ```julia
   Pkg.resolve()
   ```
2. **Julia Version Compatibility**: Check the `compat` section in `Project.toml` to ensure you're using a compatible Julia version.

---

## Contributing

If you wish to contribute to the project:

1. Fork the repository.
2. Create a new branch for your changes.
3. Submit a pull request with a description of your changes.

