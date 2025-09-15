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

    def to_s
      <<~BUILDING
        Building:
          Floors: #{@floors} (#{floor_range})
          Basement floors: #{@basement_floors}
          Total floors: #{total_floors}
          Elevators: #{@elevators.length}
          Waiting queues: #{@waiting_queues.keys.length} floors
      BUILDING
    end

    def status
      {
        floors: @floors,
        basement_floors: @basement_floors,
        total_floors: total_floors,
        floor_range: floor_range,
        elevator_count: @elevators.length,
        waiting_queues: @waiting_queues.transform_values(&:length)
      }
    end

    private

    def initialize_waiting_queues
      floor_range.each do |floor|
        @waiting_queues[floor] = []
      end
    end

    def create_elevators
      elevator_count = @config.elevator_count

      (1..elevator_count).each do |id|
        elevator = Elevator.new(
          id: id,
          capacity: @config.elevator_capacity,
          speed: @config.elevator_speed,
          door_open_time: @config.door_open_time,
          door_close_time: @config.door_close_time,
          service_floors: @config.service_floors || floor_range.to_a
        )

        @elevators << elevator
      end
    end
  end
end
