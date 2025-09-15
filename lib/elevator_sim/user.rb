# frozen_string_literal: true

module ElevatorSim
  class User
    attr_reader :id, :origin_floor, :destination_floor, :spawn_time
    attr_reader :current_state, :wait_start_time, :ride_start_time, :completion_time

    STATES = %i[waiting_for_elevator riding_elevator completed].freeze

    def initialize(id:, origin_floor:, destination_floor:, spawn_time:)
      @id = id
      @origin_floor = origin_floor
      @destination_floor = destination_floor
      @spawn_time = spawn_time

      @current_state = :waiting_for_elevator
      @wait_start_time = spawn_time
      @ride_start_time = nil
      @completion_time = nil
      @current_floor = origin_floor
    end

    def waiting?
      @current_state == :waiting_for_elevator
    end

    def riding?
      @current_state == :riding_elevator
    end

    def completed?
      @current_state == :completed
    end

    def going_up?
      @destination_floor > @origin_floor
    end

    def going_down?
      @destination_floor < @origin_floor
    end

    def board_elevator(current_time)
      return false unless waiting?

      @current_state = :riding_elevator
      @ride_start_time = current_time
      true
    end

    def exit_elevator(current_time)
      return false unless riding?

      @current_state = :completed
      @completion_time = current_time
      @current_floor = @destination_floor
      true
    end

    def wait_time
      return nil unless @ride_start_time

      @ride_start_time - @wait_start_time
    end

    def ride_time
      return nil unless completed?

      @completion_time - @ride_start_time
    end

    def total_time
      return nil unless completed?

      @completion_time - @spawn_time
    end

    def direction_symbol
      return "↑" if going_up?
      return "↓" if going_down?
      "→"
    end

    def to_s
      state_symbol = case @current_state
      when :waiting_for_elevator then "⏳"
      when :riding_elevator then "🚶"
      when :completed then "✅"
      end

      "User #{@id} [#{state_symbol}] #{@origin_floor}#{direction_symbol}#{@destination_floor}"
    end

    def status
      {
        id: @id,
        origin_floor: @origin_floor,
        destination_floor: @destination_floor,
        current_state: @current_state,
        spawn_time: @spawn_time,
        wait_time: wait_time,
        ride_time: ride_time,
        total_time: total_time
      }
    end

    def self.from_queue_data(person_data)
      new(
        id: person_data["id"],
        origin_floor: person_data["origin_floor"],
        destination_floor: person_data["destination_floor"],
        spawn_time: person_data["spawn_time"]
      )
    end
  end
end
