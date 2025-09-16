# Claude Code Assistant Instructions

This file contains helpful information for Claude Code when working on this project.

## Project Overview
Elevator simulation CLI written in Ruby that allows users to test different elevator dispatch algorithms with configurable parameters and real-time visualization.

## Development Commands

### Running the CLI
```bash
./bin/elevator-sim
```

### Testing Dependencies
```bash
bundle install
bundle exec ruby -c lib/elevator_sim.rb  # Syntax check
bundle exec ruby -e "require_relative 'lib/elevator_sim'; config = ElevatorSim::Configuration.load('config/default.toml'); puts config.building_floors"  # Test config loading
```

### Queue Management Commands
```bash
# Generate queues
./bin/elevator-sim generate-queue --name rush_hour
./bin/elevator-sim generate-queue --name evening --config config/custom.toml

# View queues
./bin/elevator-sim show-queue --name rush_hour --limit 5
./bin/elevator-sim list-queues

# Test queue loading
bundle exec ruby -e "require_relative 'lib/elevator_sim'; queue = ElevatorSim::Queue.load('queues/default.json'); puts queue.people.first"
```

### Algorithm Development Commands
```bash
# Test algorithm loading
bundle exec ruby -e "require_relative 'lib/elevator_sim'; config = ElevatorSim::Configuration.load('config/default.toml'); building = ElevatorSim::Building.new(config); algorithm = ElevatorSim::AlgorithmLoader.load_from_file('algorithms/fifo.rb', building, config); puts algorithm.class.name"

# Validate algorithm syntax
bundle exec ruby -c algorithms/fifo.rb
```

### Simulation Engine Commands
```bash
# Test simulation components
bundle exec ruby -e "require_relative 'lib/elevator_sim'; config = ElevatorSim::Configuration.load('config/default.toml'); building = ElevatorSim::Building.new(config); puts building.status"

# Run full simulation
./bin/elevator-sim run --algorithm algorithms/fifo.rb

# Interactive step-by-step simulation
./bin/elevator-sim simulate --algorithm algorithms/fifo.rb --interactive

# Run with custom queue
./bin/elevator-sim run --algorithm algorithms/fifo.rb --queue test
```

### Linting and Type Checking
```bash
bundle exec standardrb --fix  # Ruby linting with Standard
bundle exec rspec             # Run tests
```

## Project Structure

- `bin/elevator-sim` - Main executable CLI entry point
- `lib/elevator_sim/` - Core library modules
- `config/` - TOML configuration files
- `algorithms/` - User-provided elevator dispatch algorithms
- `examples/` - Example configurations and algorithms

## Key Dependencies

- **TTY toolkit** - For fancy CLI interface with real-time visualization
  - `tty-box`, `tty-cursor`, `tty-prompt`, `tty-progressbar`, `tty-screen`, `tty-spinner`, `tty-table`, `tty-command`
  - `pastel` - Terminal colors
- **tomlrb** - For TOML configuration parsing
- **standard** - Ruby linting (zero-configuration style guide)
- **rspec** - Testing framework
- **Ruby 3.4.5** - Managed by mise

## Development Notes

- Use `frozen_string_literal: true` in all Ruby files
- Follow Ruby naming conventions (snake_case for methods/variables)
- Implement proper error handling with user-friendly messages
- Keep CLI output concise but informative
- Use TTY components for interactive elements and visualization

## Testing Strategy

- Unit tests for core simulation classes (Building, Elevator, User)
- Integration tests for algorithm loading and execution
- CLI command tests
- Configuration file parsing tests

## Algorithm Interface

Custom algorithms should inherit from `ElevatorSim::Algorithm`:
```ruby
class CustomAlgorithm < ElevatorSim::Algorithm
  def initialize(building, config)
    super
    # Your initialization here
  end

  def dispatch(call_requests, elevator_states)
    # call_requests: [{floor: 5, direction: :up, user: User, timestamp: 1.6}]
    # elevator_states: [{id: 1, current_floor: 3, state: :idle, passengers: 2, capacity: 8}]
    # Return: [{elevator_id: 1, action: :move_to_floor, target_floor: 5}]
    []
  end
end
```

## Simulation Statistics

The simulation tracks comprehensive metrics:
- **Total Users**: Number of people spawned during simulation
- **Completed Users**: Number who successfully reached their destination  
- **Average Wait Time**: Time from spawn to boarding elevator
- **Average Ride Time**: Time from boarding to alighting
- **Average Total Time**: Total time from spawn to completion
- **Elevator Utilization**: Percentage of time elevators are active (not idle)