# frozen_string_literal: true

module ElevatorSim
  # Main simulation engine that orchestrates elevators, users, and timing
  class Simulation
    def initialize(config, algorithm, queue = nil)
      @config = config
      @building = Building.new(config)
      @algorithm = algorithm
      @queue = queue
      @current_time = 0.0
      @users = []
      @completed_users = []
      @call_requests = []
      @running = false
    end

    def run
      initialize_simulation
      @running = true

      while @running && @current_time < duration_seconds
        step_simulation
      end

      finalize_simulation
      generate_statistics
    end

    def step_simulation
      # 1. Spawn new users based on spawn rate and queue
      spawn_users

      # 2. Process user interactions (button presses, boarding, exiting)
      process_user_interactions

      # 3. Get algorithm decisions for call requests
      assignments = @algorithm.dispatch(@call_requests.dup, elevator_states)

      # 4. Apply algorithm assignments to elevators
      apply_assignments(assignments)

      # 5. Update elevator positions and states
      @building.elevators.each { |elevator| elevator.update(time_step) }

      # 6. Handle elevator arrivals and boarding
      handle_elevator_arrivals

      # 7. Update user states and timing
      @users.each { |user| user.update(@current_time) }

      # 8. Remove completed users
      remove_completed_users

      # 9. Advance time
      @current_time += time_step
    end

    def stop
      @running = false
    end

    def statistics
      {
        simulation_time: @current_time,
        total_users: @users.length + @completed_users.length,
        completed_users: @completed_users.length,
        average_wait_time: calculate_average_wait_time,
        average_ride_time: calculate_average_ride_time,
        average_total_time: calculate_average_total_time,
        elevator_utilization: calculate_elevator_utilization
      }
    end

    def current_state
      {
        time: @current_time,
        building: @building,
        users: @users,
        call_requests: @call_requests,
        statistics: statistics
      }
    end

    private

    attr_reader :config, :building, :algorithm

    def initialize_simulation
      @algorithm.initialize_simulation if @algorithm.respond_to?(:initialize_simulation)
    end

    def finalize_simulation
      @algorithm.finalize_simulation(statistics) if @algorithm.respond_to?(:finalize_simulation)
    end

    def duration_seconds
      @config.simulation_duration_minutes * 60.0
    end

    def time_step
      0.1 # 100ms time step
    end

    def spawn_users
      return unless @queue

      # Check if it's time to spawn the next user from the queue
      next_user_data = @queue.peek_next_user(@current_time)
      return unless next_user_data

      # Create and add the user
      user = User.new(
        start_floor: next_user_data[:start_floor],
        destination_floor: next_user_data[:destination_floor],
        spawn_time: @current_time
      )

      @users << user
      @building.add_user_to_floor(user, user.start_floor)
      @queue.pop_next_user # Remove from queue
    end

    def process_user_interactions
      @users.each do |user|
        case user.state
        when :waiting_for_elevator
          # User presses button if they haven't already
          if user.can_press_button?(@current_time)
            direction = (user.destination_floor > user.start_floor) ? :up : :down
            add_call_request(user.start_floor, direction, user)
            user.press_button(@current_time)
          end

        when :riding_elevator
          # Check if user has reached destination
          elevator = find_elevator_with_user(user)
          if elevator&.current_floor == user.destination_floor && elevator.doors_open?
            user.exit_elevator(@current_time)
            elevator.remove_passenger(user)
            @building.remove_user_from_floor(user, user.destination_floor)
          end
        end
      end
    end

    def add_call_request(floor, direction, user)
      # Only add if not already pending
      existing = @call_requests.find { |req| req[:floor] == floor && req[:direction] == direction }
      return if existing

      @call_requests << {
        floor: floor,
        direction: direction,
        user: user,
        timestamp: @current_time
      }
    end

    def elevator_states
      @building.elevators.map do |elevator|
        {
          id: elevator.id,
          current_floor: elevator.current_floor,
          state: elevator.state,
          passengers: elevator.passengers.length,
          capacity: elevator.capacity,
          target_floor: elevator.target_floor,
          service_floors: elevator.service_floors
        }
      end
    end

    def apply_assignments(assignments)
      assignments.each do |assignment|
        elevator = @building.find_elevator(assignment[:elevator_id])
        next unless elevator

        case assignment[:action]
        when :move_to_floor
          elevator.move_to_floor(assignment[:target_floor])
          # Don't remove call requests until elevator actually arrives and opens doors
        when :stop
          elevator.stop
        when :open_doors
          elevator.open_doors
        when :close_doors
          elevator.close_doors
        end
      end
    end

    def handle_elevator_arrivals
      @building.elevators.each do |elevator|
        # Check if elevator has just arrived at a floor and is idle (not moving)
        if elevator.state == :idle && elevator.target_floor.nil?
          floor = elevator.current_floor

          # Find users waiting on this floor who want to board this elevator
          waiting_users = @users.select do |user|
            user.state == :waiting_for_elevator &&
              user.start_floor == floor &&
              elevator.can_service_floor?(user.destination_floor)
          end

          if waiting_users.any? && !elevator.full?
            elevator.open_doors

            # Board users
            waiting_users.each do |user|
              if elevator.add_passenger(user)
                user.board_elevator(@current_time)

                # Remove this user's call request
                @call_requests.reject! do |req|
                  req[:user] == user
                end
              end
              break if elevator.full?
            end
          end
        end
      end
    end

    def remove_satisfied_calls(floor)
      @call_requests.reject! { |req| req[:floor] == floor }
    end

    def find_elevator_with_user(user)
      @building.elevators.find { |elevator| elevator.passengers.include?(user) }
    end

    def remove_completed_users
      completed = @users.select { |user| user.state == :completed }
      @completed_users.concat(completed)
      @users.reject! { |user| user.state == :completed }
    end

    def calculate_average_wait_time
      return 0.0 if @completed_users.empty?

      total_wait_time = @completed_users.sum(&:wait_time)
      total_wait_time / @completed_users.length
    end

    def calculate_average_ride_time
      return 0.0 if @completed_users.empty?

      total_ride_time = @completed_users.sum(&:ride_time)
      total_ride_time / @completed_users.length
    end

    def calculate_average_total_time
      return 0.0 if @completed_users.empty?

      total_time = @completed_users.sum(&:total_time)
      total_time / @completed_users.length
    end

    def calculate_elevator_utilization
      return 0.0 if @building.elevators.empty? || @current_time == 0

      total_active_time = @building.elevators.sum(&:active_time)
      total_possible_time = @building.elevators.length * @current_time
      total_active_time / total_possible_time
    end

    def generate_statistics
      puts "\n📊 Simulation Statistics"
      puts "=" * 50
      puts "⏱️  Duration: #{@current_time.round(1)}s (#{(@current_time / 60.0).round(1)} minutes)"
      puts "👥 Total Users: #{@users.length + @completed_users.length}"
      puts "✅ Completed: #{@completed_users.length}"
      puts "⏳ Average Wait Time: #{calculate_average_wait_time.round(2)}s"
      puts "🚗 Average Ride Time: #{calculate_average_ride_time.round(2)}s"
      puts "🕒 Average Total Time: #{calculate_average_total_time.round(2)}s"
      puts "📈 Elevator Utilization: #{(calculate_elevator_utilization * 100).round(1)}%"
    end
  end
end
