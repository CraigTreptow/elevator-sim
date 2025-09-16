# Elevator Simulation CLI

A Ruby CLI application that simulates elevator systems with user-provided algorithms. Compare algorithm performance with real-time visualization and detailed statistics.

## Features

- 🏢 **Configurable buildings** with multiple floors and elevators
- 🔄 **Pluggable algorithms** - bring your own elevator dispatch logic
- 📊 **Performance tracking** - compare wait times, travel times, and efficiency
- 🎨 **Real-time visualization** - fancy CLI interface with live elevator positions
- ⚙️ **TOML configuration** - easily adjust all simulation parameters

## Requirements

- **[mise](https://mise.jdx.dev/)** - For Ruby version management
- **Ruby 3.4.5** - Will be installed automatically by mise

## Installation

```bash
git clone https://github.com/CraigTreptow/elevator-sim.git
cd elevator-sim
mise install    # Install Ruby 3.4.5 using mise
bundle install  # Install gem dependencies
```

## Usage

### Quick Start

1. **Run your first simulation**:
```bash
./bin/elevator-sim run --algorithm algorithms/fifo.rb
```

2. **Generate a reproducible queue for testing**:
```bash
./bin/elevator-sim generate-queue --name test_scenario
./bin/elevator-sim run --algorithm algorithms/fifo.rb --queue test_scenario
```

3. **Step through a simulation interactively**:
```bash
./bin/elevator-sim simulate --algorithm algorithms/fifo.rb --interactive
```

### Detailed Command Reference

#### Simulation Commands

**Basic simulation run**:
```bash
# Run with default configuration
./bin/elevator-sim run --algorithm algorithms/fifo.rb

# Use custom configuration
./bin/elevator-sim run --config config/custom.toml --algorithm algorithms/fifo.rb

# Use a specific queue for reproducible results
./bin/elevator-sim run --algorithm algorithms/fifo.rb --queue rush_hour
```

**Interactive simulation** (step-by-step execution):
```bash
# Interactive mode - press Enter to advance each step
./bin/elevator-sim simulate --algorithm algorithms/fifo.rb --interactive

# Non-interactive mode (same as 'run' but different output format)
./bin/elevator-sim simulate --algorithm algorithms/fifo.rb
```

#### Queue Management Commands

**Generate queues** for reproducible testing:
```bash
# Generate with default configuration
./bin/elevator-sim generate-queue --name office_hours

# Generate with custom configuration and output location
./bin/elevator-sim generate-queue --name peak_traffic --config config/busy.toml --output queues/peak.json
```

**Inspect queues**:
```bash
# Show first 10 people in queue
./bin/elevator-sim show-queue --name office_hours

# Show first 20 people
./bin/elevator-sim show-queue --name office_hours --limit 20

# List all available queues
./bin/elevator-sim list-queues
```

#### Configuration and Status Commands

**View building configuration**:
```bash
# View default building setup
./bin/elevator-sim show-building

# View custom configuration
./bin/elevator-sim show-building --config config/skyscraper.toml
```

**Get help**:
```bash
# Show all available commands
./bin/elevator-sim

# Show version
./bin/elevator-sim version
```

### Common Workflows

#### Algorithm Development Workflow

1. **Create your algorithm** (see [Writing Algorithms](#writing-algorithms))
2. **Generate test queues** for consistent testing:
```bash
./bin/elevator-sim generate-queue --name light_traffic
./bin/elevator-sim generate-queue --name heavy_traffic --config config/busy.toml
```

3. **Test your algorithm**:
```bash
./bin/elevator-sim run --algorithm algorithms/your_algorithm.rb --queue light_traffic
./bin/elevator-sim run --algorithm algorithms/your_algorithm.rb --queue heavy_traffic
```

4. **Debug with interactive mode**:
```bash
./bin/elevator-sim simulate --algorithm algorithms/your_algorithm.rb --queue light_traffic --interactive
```

#### Algorithm Comparison Workflow

1. **Generate a standard test queue**:
```bash
./bin/elevator-sim generate-queue --name benchmark
```

2. **Test multiple algorithms with the same queue**:
```bash
./bin/elevator-sim run --algorithm algorithms/fifo.rb --queue benchmark > results_fifo.txt
./bin/elevator-sim run --algorithm algorithms/your_algorithm.rb --queue benchmark > results_yours.txt
```

3. **Compare the statistics** (see [Understanding Statistics](#understanding-statistics))

#### Performance Testing Workflow

1. **Generate different scenario queues**:
```bash
# Light traffic (default settings)
./bin/elevator-sim generate-queue --name light

# Heavy traffic (increase spawn rate in config)
./bin/elevator-sim generate-queue --name heavy --config config/busy.toml

# Long duration test
./bin/elevator-sim generate-queue --name endurance --config config/60min.toml
```

2. **Test your algorithm across scenarios**:
```bash
for scenario in light heavy endurance; do
  echo "Testing $scenario scenario..."
  ./bin/elevator-sim run --algorithm algorithms/your_algorithm.rb --queue $scenario
done
```

## Configuration

Create TOML configuration files to define your simulation parameters:

```toml
[building]
floors = 20
basement_floors = 2

[elevators.main]
count = 4
capacity = 8
speed_floors_per_second = 2.5
door_open_time = 3.0
door_close_time = 2.0
service_floors = [1, 20]

[simulation]
duration_minutes = 60
user_spawn_rate = 0.5
random_seed = 42

[users]
movement_speed = 1.0
button_press_delay = 0.5
floor_distribution = "uniform"  # uniform, weighted, rush_hour
```

## Writing Algorithms

Create Ruby classes that inherit from ElevatorSim::Algorithm:

```ruby
class MyAlgorithm < ElevatorSim::Algorithm
  def initialize(building, config)
    super
    # Your initialization here
  end

  def dispatch(call_requests, elevator_states)
    # Your algorithm logic here
    # call_requests: [{floor: 5, direction: :up, user: User}]
    # elevator_states: [{id: 1, current_floor: 3, state: :idle, passengers: 2}]
    # Return: [{elevator_id: 1, action: :move_to_floor, target_floor: 5}]
    []
  end
end
```

See `algorithms/fifo.rb` for a complete example implementing First In, First Out dispatch.

## Real-time Visualization

Run with `--visual` flag for live interactive display:

```bash
./bin/elevator-sim simulate --algorithm algorithms/fifo.rb --interactive --visual
```

The visualization shows a clean, real-time view:

```
────────────────────────────────────────────────────────────
🏢 Elevator Simulation | 15.3s elapsed (0.3min)
────────────────────────────────────────────────────────────

Building View
──────────────────────────────
Floor 10
Floor  9
Floor  8
Floor  7  ▲E1
Floor  6  
Floor  5  ◉E2 👤👤
Floor  4
Floor  3  
Floor  2
Floor  1
Floor  0
Floor -1

📊 Live Statistics
──────────────────────────────
👥 Users         ▓▓▓▓▓▓░░░░ 12/18       
⏳ Avg Wait      ▓▓▓▓▓▓▓▓░░ 4.2s        
📈 Utilization   ▓▓▓▓▓▓▓▓▓░ 87.5%       
📞 Active Calls  3
```

**Elevator States:**
- `▲E1` Moving up
- `▼E1` Moving down  
- `◉E1` Doors open/loading
- `█E1` Occupied but idle
- `□E1` Empty and idle

**User Indicators:**
- `👤` Waiting passengers (shows up to 5, with count for more)

## Development Status

✅ Basic CLI structure with commands (`run`, `simulate`, `generate-queue`, `show-queue`, `list-queues`, `show-building`)  
✅ Ruby 3.4.5 version management with mise  
✅ Dependencies and fancy CLI components (TTY toolkit, StandardRB)  
✅ TOML configuration system with accessor methods  
✅ Queue management system with reproducible people generation  
✅ Core simulation classes - Building, Elevator, User, Algorithm interface  
✅ Simulation engine with time-based orchestration and statistics  
✅ Working CLI simulation with comprehensive statistics output
✅ Interactive step-by-step simulation mode with `--interactive` flag
✅ FIFO algorithm example implementation with comprehensive API documentation
✅ Real-time visualization with clean terminal UI and live statistics

## Understanding Statistics

### Simulation Output

Every simulation provides comprehensive statistics to evaluate algorithm performance:

```
📊 Simulation Statistics
==================================================
⏱️  Duration: 600.0s (10.0 minutes)
👥 Total Users: 173
✅ Completed: 12
⏳ Average Wait Time: 2.59s
🚗 Average Ride Time: 11.04s
🕒 Average Total Time: 13.63s
📈 Elevator Utilization: 98.4%
```

### Key Metrics Explained

#### **Total Users** 👥
- **What it means**: Number of people who requested elevator service during the simulation
- **Interpretation**: This depends on your configuration settings (spawn rate, duration)
- **Comparison**: Should be identical when comparing algorithms with the same queue

#### **Completed Users** ✅
- **What it means**: Number of people who successfully reached their destination
- **Interpretation**: Higher completion rate indicates better algorithm performance
- **Good performance**: 80-95% completion rate in typical scenarios
- **Poor performance**: <50% completion rate suggests algorithm issues

#### **Average Wait Time** ⏳
- **What it means**: Time from when a person presses the elevator button until they board
- **Interpretation**: Lower wait times = better user experience
- **Excellent**: <5 seconds
- **Good**: 5-15 seconds  
- **Poor**: >30 seconds
- **Critical insight**: This is often the most important user-facing metric

#### **Average Ride Time** 🚗
- **What it means**: Time from boarding the elevator until reaching destination
- **Interpretation**: Depends on building height and elevator speed settings
- **Analysis**: Significant variations between algorithms may indicate:
  - Inefficient routing (stopping at unnecessary floors)
  - Better/worse passenger grouping strategies

#### **Average Total Time** 🕒
- **What it means**: Complete journey time (Wait Time + Ride Time)
- **Interpretation**: Overall user experience metric
- **Use case**: Best single metric for comparing algorithm effectiveness

#### **Elevator Utilization** 📈
- **What it means**: Percentage of time elevators are actively moving or serving passengers (not idle)
- **Interpretation**: 
  - **High utilization (80-95%)**: Elevators are efficiently used, but may indicate system stress
  - **Medium utilization (50-80%)**: Balanced efficiency with capacity for demand spikes
  - **Low utilization (<50%)**: Either low demand or inefficient algorithm
  - **Very high utilization (>95%)**: System likely overwhelmed

### Comparing Algorithm Performance

#### Superior Algorithm Indicators

✅ **Better algorithm will show**:
- Higher completion rate (more users reach destination)
- Lower average wait time (faster response to calls)
- Lower average total time (better overall experience)
- Appropriate utilization for the demand level

#### Poor Algorithm Indicators

❌ **Worse algorithm will show**:
- Low completion rate (many users never get served)
- High wait times (slow to respond to calls)
- Very high utilization with poor completion (inefficient movement)
- Extremely low utilization (algorithm not dispatching elevators)

### Algorithm Comparison Examples

#### Example 1: Efficient vs. Inefficient

**Algorithm A (Efficient)**:
```
👥 Total Users: 173
✅ Completed: 156 (90% completion)
⏳ Average Wait Time: 8.2s
🚗 Average Ride Time: 12.1s  
🕒 Average Total Time: 20.3s
📈 Elevator Utilization: 76%
```

**Algorithm B (Inefficient)**:
```
👥 Total Users: 173  
✅ Completed: 89 (51% completion)
⏳ Average Wait Time: 28.5s
🚗 Average Ride Time: 15.7s
🕒 Average Total Time: 44.2s
📈 Elevator Utilization: 94%
```

**Analysis**: Algorithm A is clearly superior - much higher completion rate, shorter wait times, and reasonable utilization. Algorithm B's high utilization with poor completion suggests wasted movement.

#### Example 2: Different Optimization Strategies

**Algorithm C (Wait-Time Optimized)**:
```
👥 Total Users: 173
✅ Completed: 142 (82% completion)
⏳ Average Wait Time: 4.1s
🚗 Average Ride Time: 18.9s
🕒 Average Total Time: 23.0s
📈 Elevator Utilization: 85%
```

**Algorithm D (Ride-Time Optimized)**:
```
👥 Total Users: 173
✅ Completed: 138 (80% completion)  
⏳ Average Wait Time: 12.7s
🚗 Average Ride Time: 9.2s
🕒 Average Total Time: 21.9s
📈 Elevator Utilization: 72%
```

**Analysis**: Both algorithms are effective but optimize different aspects. Algorithm C responds faster to calls but takes longer routes. Algorithm D makes users wait longer but provides faster rides. Algorithm D has slightly better total time.

### Performance Tuning Guidelines

#### If you see low completion rates:
- Algorithm may not be dispatching elevators to all floors
- Check if elevators are getting "stuck" serving high-traffic floors
- Verify algorithm handles edge cases (basement floors, service restrictions)

#### If you see high wait times:
- Algorithm may be too conservative in dispatching elevators
- Consider more aggressive call response strategies
- Check if algorithm is properly prioritizing waiting passengers

#### If you see very high utilization with poor results:
- Elevators may be making unnecessary trips
- Algorithm might be inefficiently routing elevators
- Consider passenger batching strategies

#### If you see very low utilization:
- Algorithm may not be dispatching elevators when needed
- Check if algorithm is properly detecting call requests
- Verify elevator state management is working correctly

## License

MIT License - see [LICENSE](LICENSE) file.
