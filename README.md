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

### Basic simulation
```bash
./bin/elevator-sim run --config config/default.toml --algorithm algorithms/fifo.rb
```

### Interactive mode with real-time visualization
```bash
./bin/elevator-sim simulate --config config/office_building.toml --algorithm algorithms/nearest_car.rb --interactive
```

### Compare algorithms
```bash
./bin/elevator-sim compare --config config/default.toml \
  --algorithms algorithms/fifo.rb,algorithms/nearest_car.rb,algorithms/destination_dispatch.rb
```

### Configuration wizard
```bash
./bin/elevator-sim init
```

### Check CLI is working
```bash
./bin/elevator-sim
```

### Queue Management
```bash
# Generate a named queue
./bin/elevator-sim generate-queue --name rush_hour

# Show queue contents  
./bin/elevator-sim show-queue --name rush_hour

# List all available queues
./bin/elevator-sim list-queues
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

The interactive mode shows:

```
┌─ Elevator Simulation ──────── 15:30 elapsed ──┐
│ Floor 10 │ ▲E1  │     │     │ │ 👤👤    │ Wait │
│ Floor 9  │     │ ▼E2  │     │ │ 👤      │ 2.3s │
│ Floor 8  │     │     │ ═E3═ │ │         │ 1.1s │
│ Floor 7  │     │     │     │ │ 👤👤👤  │ 4.2s │
└──────────────────────────────────────────────────┘

Statistics:
▓▓▓▓▓▓▓░░░ 67% - Average Wait Time: 2.8s
▓▓▓▓▓▓▓▓░░ 82% - Elevator Utilization
```

**Elevator States:**
- `▲E1` Moving up
- `▼E1` Moving down  
- `═E1═` Stopped (doors closed)
- `◉E1` Stopped (doors open)
- `│E1│` Idle/waiting

## Development Status

✅ Basic CLI structure with commands (`run`, `simulate`, `compare`, `init`)  
✅ Ruby 3.4.5 version management with mise  
✅ Dependencies and fancy CLI components (TTY toolkit, StandardRB)  
✅ TOML configuration system with accessor methods  
✅ Queue management system with reproducible people generation  
✅ Core simulation classes - Building, Elevator, User, Algorithm interface  
✅ Simulation engine with time-based orchestration and statistics  
🔲 Real-time visualization

## License

MIT License - see [LICENSE](LICENSE) file.
