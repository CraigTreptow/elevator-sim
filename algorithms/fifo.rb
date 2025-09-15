# frozen_string_literal: true

# First In, First Out (FIFO) Algorithm
# Dispatches elevators to the oldest call request first
class FifoAlgorithm < ElevatorSim::Algorithm
  def initialize(building, config)
    super
    @call_queue = []
  end

  def dispatch(call_requests, elevator_states)
    assignments = []

    # Add new calls to our queue
    call_requests.each do |call|
      @call_queue << call unless @call_queue.any? { |existing| existing[:floor] == call[:floor] }
    end

    # Process calls in FIFO order
    @call_queue.dup.each do |call|
      # Find an available elevator
      available_elevator = find_available_elevator(elevator_states)

      if available_elevator
        assignments << {
          elevator_id: available_elevator[:id],
          action: :move_to_floor,
          target_floor: call[:floor]
        }

        # Remove this call from queue
        @call_queue.delete(call)
      end
    end

    assignments
  end

  private

  def find_available_elevator(elevator_states)
    # Find idle elevators first
    idle_elevator = elevator_states.find { |elevator| elevator[:state] == :idle }
    return idle_elevator if idle_elevator

    # If no idle elevators, find one that's not moving
    elevator_states.find { |elevator| ![:moving_up, :moving_down].include?(elevator[:state]) }
  end
end
