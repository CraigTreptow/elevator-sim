# frozen_string_literal: true

module ElevatorSim
  class Building
    attr_reader :floors, :basement_floors, :elevators, :waiting_queues

    def initialize(config)
      @config = config
      @floors = config.building_floors
      @basement_floors = config.basement_floors || 0
      @elevators = []
      @waiting_queues = {}

      initialize_waiting_queues
      create_elevators
    end

    def total_floors
      @floors + @basement_floors
    end

    def floor_range
      basement_start = (@basement_floors > 0) ? -@basement_floors : 1
      basement_start..@floors
    end

    def valid_floor?(floor)
      floor_range.include?(floor)
    end

    def add_person_to_queue(floor, person)
      raise "Invalid floor: #{floor}" unless valid_floor?(floor)

      @waiting_queues[floor] << person
    end

    def people_waiting_on_floor(floor)
      @waiting_queues[floor]&.length || 0
    end

    def remove_people_from_queue(floor, count)
      return [] unless @waiting_queues[floor]

      @waiting_queues[floor].shift(count)
    end

    def elevator_by_id(elevator_id)
      @elevators.find { |e| e.id == elevator_id }
    end

    private

    def initialize_waiting_queues
      floor_range.each do |floor|
        @waiting_queues[floor] = []
      end
    end

    def create_elevators
      # TODO: Create elevators when Elevator class is implemented
      # For now, just initialize empty array
      @elevators = []
    end
  end
end
