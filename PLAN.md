# Elevator Simulation CLI Plan

## Project Overview
A Ruby CLI application that simulates elevator systems with user-provided algorithms. The simulation tracks statistics to help users compare algorithm performance while keeping all other variables constant.

## Core Features
- **Multiple elevators** in a single building with configurable floor ranges
- **Configurable building** with X number of stories
- **User simulation** with spawn rates, movement patterns, and destinations
- **Pluggable algorithms** - users provide their own elevator dispatch logic
- **Performance statistics** - track wait times, travel times, efficiency metrics
- **TOML configuration** for all simulation parameters
- **Fancy CLI interface** with real-time visualization using TTY toolkit

## Implementation Plan

### 1. Core Infrastructure
- [x] Initialize git repository and create initial project structure
- [x] Set up mise-en-place configuration for Ruby version management
- [x] Create basic Ruby CLI application structure with main entry point
- [x] Set up Gemfile with fancy CLI dependencies (TTY toolkit, TOML parsing)

### 2. Configuration System
- [x] Create TOML configuration system for simulation parameters

### 3. Queue Management System  
- [x] Create Queue class for generating reproducible people data
- [x] Add named queue management and CLI commands (generate-queue, show-queue, list-queues)

### 4. Simulation Components
- [ ] Implement Building class with configurable floors and elevator setup
- [ ] Create Elevator class with movement, door timing, and floor range logic
- [ ] Implement User/Passenger class with spawn rates and movement patterns
- [ ] Create pluggable algorithm interface for user-provided elevator algorithms
- [ ] Build simulation engine to orchestrate elevators, users, and timing
- [ ] Implement statistics tracking system for performance metrics

### 5. User Interface & Finalization
- [ ] Set up TTY toolkit gems for fancy CLI interface
- [ ] Create real-time visualization showing elevator positions and states
- [ ] Create CLI argument parsing and command structure with TTY components
- [ ] Add executable permissions and shebang for CLI usage
- [ ] Create .gitignore file appropriate for Ruby projects
- [ ] Set up basic error handling and user-friendly output
- [ ] Create example algorithms and TOML configuration files
- [ ] Create initial commit and prepare for GitHub repository

## Configuration Structure (TOML)
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

[users]
movement_speed = 1.0
button_press_delay = 0.5
```

## Statistics Tracked
- Average wait time per user
- Average travel time
- Elevator utilization
- Energy efficiency metrics
- Algorithm comparison reports

## CLI Visualization Features
- **Real-time building view** showing elevator positions per floor
- **Elevator state indicators**:
  - `▲E1` = Moving up
  - `▼E1` = Moving down  
  - `═E1═` = Stopped (doors closed)
  - `◉E1` = Stopped (doors open)
  - `│E1│` = Idle/waiting
- **Passenger indicators** (`👤👤`) showing people waiting per floor
- **Live statistics dashboard** with progress bars and metrics
- **Interactive controls** for pause/resume/speed adjustment
- **Color coding** for different elevator states and performance metrics