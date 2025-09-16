# frozen_string_literal: true

# Comprehensive Algorithm Example with Full API Documentation
# This algorithm demonstrates all available API features and data structures
class DocumentedAlgorithm < ElevatorSim::Algorithm
  def initialize(building, config)
    super
    
    # Access building information
    puts "Building has #{building.total_floors} floors (#{building.floor_range})"
    puts "#{building.elevators.length} elevators available"
    
    # Access configuration
    puts "Simulation duration: #{config.duration_minutes} minutes"
    puts "User spawn rate: #{config.user_spawn_rate} people/second"
    
    @algorithm_state = {
      assigned_calls: {},  # Track which calls we've assigned
      elevator_targets: {}  # Track where we've sent each elevator
    }
  end

  # Main dispatch method called every simulation step (0.1 seconds)
  def dispatch(call_requests, elevator_states)
    puts "\n=== DISPATCH CALLED ==="
    puts "Call requests: #{call_requests.length}"
    puts "Elevator states: #{elevator_states.length}"
    
    # Document the call_requests structure
    call_requests.each do |call|
      puts "📞 Call: Floor #{call[:floor]} going #{call[:direction]} (timestamp: #{call[:timestamp]})"
      # Available fields in call_requests:
      # - call[:floor] - Integer - Floor number where call was made
      # - call[:direction] - Symbol - :up or :down direction requested  
      # - call[:user] - User object - The person who made the call
      # - call[:timestamp] - Float - When the call was made (simulation time)
    end
    
    # Document the elevator_states structure  
    elevator_states.each do |elevator|
      puts "🏢 Elevator #{elevator[:id]}: Floor #{elevator[:current_floor]}, " \
           "State: #{elevator[:state]}, Passengers: #{elevator[:passengers]}/#{elevator[:capacity]}"
      # Available fields in elevator_states:
      # - elevator[:id] - Integer - Unique elevator identifier
      # - elevator[:current_floor] - Float - Current floor position (can be between floors)
      # - elevator[:state] - Symbol - Current state (see AVAILABLE_STATES below)
      # - elevator[:passengers] - Integer - Number of people currently in elevator
      # - elevator[:capacity] - Integer - Maximum passenger capacity
      # - elevator[:target_floor] - Integer/nil - Floor elevator is moving toward
      # - elevator[:service_floors] - Array - Floors this elevator can visit
    end
    
    assignments = []
    
    # Process each call request
    call_requests.each do |call|
      # Find the best elevator for this call
      best_elevator = find_best_elevator(call, elevator_states)
      
      if best_elevator
        # Create an assignment
        assignment = {
          elevator_id: best_elevator[:id],
          action: :move_to_floor,           # See AVAILABLE_ACTIONS below
          target_floor: call[:floor]
        }
        assignments << assignment
        
        puts "✅ Assigning Elevator #{best_elevator[:id]} to Floor #{call[:floor]}"
        
        # Update our tracking
        @algorithm_state[:assigned_calls][call[:floor]] = true
        @algorithm_state[:elevator_targets][best_elevator[:id]] = call[:floor]
      else
        puts "❌ No available elevator for Floor #{call[:floor]}"
      end
    end
    
    puts "📋 Returning #{assignments.length} assignments"
    assignments
  end

  private

  # AVAILABLE ELEVATOR STATES:
  # :idle - Elevator is stationary and available
  # :moving_up - Elevator is moving upward
  # :moving_down - Elevator is moving downward  
  # :doors_opening - Doors are opening (brief state)
  # :doors_closing - Doors are closing (brief state)
  
  # AVAILABLE ACTIONS you can return:
  # :move_to_floor - Send elevator to specific floor
  # :stop - Stop elevator at current floor
  # :open_doors - Open elevator doors
  # :close_doors - Close elevator doors
  
  def find_best_elevator(call, elevator_states)
    # Example strategy: Find closest idle elevator
    
    # Filter to available elevators
    available = elevator_states.select do |elevator|
      # Check if elevator can service this floor
      elevator[:service_floors].include?(call[:floor]) &&
      # Check if elevator is available (not overloaded)
      elevator[:passengers] < elevator[:capacity] &&
      # Prefer idle elevators, but accept non-moving ones
      [:idle, :doors_opening, :doors_closing].include?(elevator[:state])
    end
    
    return nil if available.empty?
    
    # Find closest elevator
    closest = available.min_by do |elevator|
      distance = (elevator[:current_floor] - call[:floor]).abs
      
      # Add penalty for busy elevators
      penalty = elevator[:state] == :idle ? 0 : 5
      
      distance + penalty
    end
    
    closest
  end
  
  # Optional: Called when simulation starts
  def initialize_simulation
    puts "🚀 Algorithm simulation starting!"
  end
  
  # Optional: Called when simulation ends  
  def finalize_simulation(statistics)
    puts "🏁 Algorithm simulation finished!"
    puts "Final stats: #{statistics}"
    # statistics contains:
    # - :simulation_time - Total simulation duration
    # - :total_users - Number of people spawned
    # - :completed_users - Number who reached destination
    # - :average_wait_time - Average time waiting for elevator
    # - :average_ride_time - Average time in elevator
    # - :average_total_time - Average total journey time
    # - :elevator_utilization - Percentage of time elevators were active
  end
end

# BUILDING OBJECT METHODS:
# - building.total_floors - Total number of floors including basement
# - building.floor_range - Range object of all valid floors (e.g., -1..10)
# - building.elevators - Array of elevator objects
# - building.valid_floor?(floor) - Check if floor number is valid
# - building.people_waiting_on_floor(floor) - Count of waiting people

# CONFIG OBJECT METHODS:
# - config.building_floors - Number of floors above ground
# - config.basement_floors - Number of basement floors  
# - config.elevator_count - Number of elevators
# - config.elevator_capacity - Passenger capacity per elevator
# - config.elevator_speed - Floors per second movement speed
# - config.door_open_time - Seconds to open doors
# - config.door_close_time - Seconds to close doors
# - config.duration_minutes - Simulation duration
# - config.user_spawn_rate - People spawned per second
# - config.random_seed - Random seed for reproducibility