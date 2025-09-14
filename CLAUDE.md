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
```

### Linting and Type Checking
When available, run these commands before committing:
```bash
# Add actual commands once we determine the linting setup
# rubocop --auto-correct  # Ruby linting
# steep check             # Type checking (if using Steep)
```

## Project Structure

- `bin/elevator-sim` - Main executable CLI entry point
- `lib/elevator_sim/` - Core library modules
- `config/` - TOML configuration files
- `algorithms/` - User-provided elevator dispatch algorithms
- `examples/` - Example configurations and algorithms

## Key Dependencies

- **TTY toolkit** - For fancy CLI interface with real-time visualization
- **tomlrb** - For TOML configuration parsing
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

Custom algorithms should implement:
```ruby
class CustomAlgorithm
  def initialize(building, elevators)
    # Setup
  end

  def dispatch(call_requests, elevator_states)
    # Return elevator assignments
  end
end
```