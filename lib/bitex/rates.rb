module Bitex
  # Exchange Rates Tree.
  # Example calculation for turning 1000 ARS in cash to USD credited
  # to your bitex balance using more_mt as the funding option.
  #     Bitex::Rates.calculate(1000, [:ars, :cash, :usd, :bitex, :more_mt])
  # Also available backwards: How many ARS should I deposit using more_mt
  # to end up with 200 USD in my bitex balance?
  #     Bitex::Rates.calculate_back([:ars, :cash, :usd, :bitex, :more_mt], 200)
  # @see https://bitex.la/developers#rates
  class Rates
    # Full exchange rates tree, gets cached locally for 60 seconds.
    def self.tree
      if @tree.nil? || @last_tree_fetch.to_i < (Time.now.to_i - 60)
        @tree = Api.public("/rates/tree").deep_symbolize_keys
        @last_tree_fetch = Time.now.to_i
      end
      @tree
    end

    def self.clear_tree_cache
      @tree = nil
      @last_tree_fetch = nil
    end

    def self.calculate_path(value, path)
      value = value.to_d
      path_to_calculator(path).each do |step|
        step.symbolize_keys!
        case step[:type].to_sym
        when :exchange
          value *= step[:rate].to_d
        when :percentual_fee
          value *= 1 - (step[:percentage].to_d / 100.to_d)
        when :fixed_fee
          value -= step[:amount].to_d
        when :minimum_fee
          value -= [step[:minimum].to_d, value * step[:percentage].to_d / 100.to_d].max
        end
      end
      value
    end

    def self.calculate_path_backwards(path, value)
      value = value.to_d
      path_to_calculator(path).each do |step|
        step.symbolize_keys!
        case step[:type].to_sym
        when :exchange
          value /= step[:rate].to_d
        when :percentual_fee
          value /= 1 - (step[:percentage].to_d / 100.to_d)
        when :fixed_fee
          value += step[:amount].to_d
        when :minimum_fee
          value = [value + step[:minimum].to_d,
            value / (1 - (step[:percentage].to_d / 100.to_d))].max
        end
      end
      value
    end

    def self.path_to_calculator(path)
      steps = tree
      begin
        path.each { |step| steps = steps[step] }
      rescue StandardError => e
        raise "InvalidPath: #{path}"
      end
      steps
    end
  end
end
