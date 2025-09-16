# frozen_string_literal: true

# First In, First Out (FIFO) Algorithm
# Dispatches elevators to the oldest call request first
# 
# Simple strategy: Handle calls in the order they were received,
# always assign the first available elevator to the oldest pending call.
class FifoAlgorithm < ElevatorSim::Algorithm
  def initialize(building, config)
    super
    @call_queue = []  # Our internal queue of pending calls
  end

  # Called every 0.1 seconds with current state
  def dispatch(call_requests, elevator_states)
    assignments = []

    # Add new calls to our queue (avoid duplicates)
    call_requests.each do |call|
      # call structure: {floor: 8, direction: :down, user: User, timestamp: 1.6}
      unless @call_queue.any? { |existing| existing[:floor] == call[:floor] }
        @call_queue << call
      end
    end

    # Process calls in FIFO order (oldest first)
    @call_queue.dup.each do |call|
      # Find an available elevator
      available_elevator = find_available_elevator(elevator_states)

      if available_elevator
        # Create assignment to send elevator to the call floor
        assignments << {
          elevator_id: available_elevator[:id],
          action: :move_to_floor,        # Available actions: :move_to_floor, :stop, :open_doors, :close_doors
          target_floor: call[:floor]
        }

        # Remove this call from our queue (it's been assigned)
        @call_queue.delete(call)
      end
      # If no elevator available, call stays in queue for next time
    end

    assignments  # Return array of assignments for simulation engine
  end

  private

  def find_available_elevator(elevator_states)
    # elevator structure: {id: 1, current_floor: 3, state: :idle, passengers: 2, capacity: 8, target_floor: nil, service_floors: [1,2,3...]}
    
    # Strategy 1: Find idle elevators first (best choice)
    idle_elevator = elevator_states.find { |elevator| elevator[:state] == :idle }
    return idle_elevator if idle_elevator

    # Strategy 2: If no idle elevators, find one that's not actively moving
    # Available states: :idle, :moving_up, :moving_down, :doors_opening, :doors_closing
    elevator_states.find { |elevator| ![:moving_up, :moving_down].include?(elevator[:state]) }
  end
end
