# frozen_string_literal: true

module ElevatorSim
  # Base class for elevator dispatch algorithms
  class Algorithm
    def initialize(building, config)
      @building = building
      @config = config
    end

    # Override this method in your algorithm implementation
    # @param call_requests [Array<Hash>] Array of call requests: {floor: 5, direction: :up, user: User}
    # @param elevator_states [Array<Hash>] Current state of all elevators
    # @return [Array<Hash>] Assignments: {elevator_id: 1, action: :move_to_floor, target_floor: 5}
    def dispatch(call_requests, elevator_states)
      raise NotImplementedError, "Algorithm must implement dispatch method"
    end

    # Optional: Called when simulation starts
    def initialize_simulation
      # Override if needed
    end

    # Optional: Called when simulation ends
    def finalize_simulation(statistics)
      # Override if needed
    end

    protected

    attr_reader :building, :config
  end

  # Algorithm loader for user-provided algorithm files
  class AlgorithmLoader
    def self.load_from_file(file_path, building, config)
      unless File.exist?(file_path)
        raise "Algorithm file not found: #{file_path}"
      end

      # Load the algorithm file
      require_relative File.expand_path(file_path)

      # Find the algorithm class
      algorithm_class = find_algorithm_class(file_path)

      # Instantiate and return
      algorithm_class.new(building, config)
    rescue LoadError => e
      raise "Failed to load algorithm file: #{e.message}"
    rescue => e
      raise "Error creating algorithm instance: #{e.message}"
    end

    private_class_method def self.find_algorithm_class(file_path)
      # Get all classes that inherit from Algorithm
      algorithm_classes = ObjectSpace.each_object(Class).select { |klass| klass < Algorithm }

      if algorithm_classes.empty?
        raise "No algorithm class found in #{file_path}. Must inherit from ElevatorSim::Algorithm"
      end

      if algorithm_classes.length > 1
        raise "Multiple algorithm classes found in #{file_path}. Only one per file allowed"
      end

      algorithm_classes.first
    end
  end
end
