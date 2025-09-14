# Elevator Simulation CLI

A Ruby CLI application that simulates elevator systems with user-provided algorithms. Compare algorithm performance with real-time visualization and detailed statistics.

## Features

- 🏢 **Configurable buildings** with multiple floors and elevators
- 🔄 **Pluggable algorithms** - bring your own elevator dispatch logic
- 📊 **Performance tracking** - compare wait times, travel times, and efficiency
- 🎨 **Real-time visualization** - fancy CLI interface with live elevator positions
- ⚙️ **TOML configuration** - easily adjust all simulation parameters

## Installation

```bash
git clone https://github.com/CraigTreptow/elevator-sim.git
cd elevator-sim
bundle install
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

## Configuration

Create TOML configuration files to define your simulation parameters:

```toml
[building]
floors = 20
basement_floors = 2

[elevators.main]
count = 4
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

Create Ruby classes that implement the elevator dispatch interface:

```ruby
class MyAlgorithm
  def initialize(building, elevators)
    @building = building
    @elevators = elevators
  end

  def dispatch(call_requests, elevator_states)
    # Your algorithm logic here
    # Return elevator assignments
  end
end
```

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

## License

MIT License - see [LICENSE](LICENSE) file.
