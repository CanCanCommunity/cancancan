# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CanCan do
  describe '.accessible_by_strategy=' do
    it 'applies to every thread' do
      CanCan.accessible_by_strategy = :left_join

      expect(Thread.new { CanCan.accessible_by_strategy }.value).to eq(:left_join)
    end

    it 'applies to every fiber' do
      CanCan.accessible_by_strategy = :left_join

      expect(Fiber.new { CanCan.accessible_by_strategy }.resume).to eq(:left_join)
    end

    it 'rejects unknown strategies' do
      expect { CanCan.accessible_by_strategy = :unknown }.to raise_error(ArgumentError)
    end

    it 'accepts every built-in strategy' do
      CanCan.valid_accessible_by_strategies.each do |strategy|
        CanCan.accessible_by_strategy = strategy

        expect(CanCan.accessible_by_strategy).to eq(strategy)
      end
    end

    it 'accepts a subclass of CanCan::ModelAdapters::Strategies::Base' do
      strategy = Class.new(CanCan::ModelAdapters::Strategies::Base)

      CanCan.accessible_by_strategy = strategy

      expect(CanCan.accessible_by_strategy).to eq(strategy)
    end

    it 'rejects a class that is not a strategy' do
      expect { CanCan.accessible_by_strategy = String }
        .to raise_error(ArgumentError, /or a subclass of CanCan::ModelAdapters::Strategies::Base/)
    end

    it 'rejects a string' do
      expect { CanCan.accessible_by_strategy = 'left_join' }.to raise_error(ArgumentError)
    end
  end

  describe '.with_accessible_by_strategy' do
    before { CanCan.accessible_by_strategy = :subquery }

    it 'overrides the strategy inside the block and restores it afterwards' do
      strategy_in_block = CanCan.with_accessible_by_strategy(:left_join) { CanCan.accessible_by_strategy }

      expect(strategy_in_block).to eq(:left_join)
      expect(CanCan.accessible_by_strategy).to eq(:subquery)
    end

    it 'restores the strategy when the block raises' do
      expect do
        CanCan.with_accessible_by_strategy(:left_join) { raise 'boom' }
      end.to raise_error('boom')

      expect(CanCan.accessible_by_strategy).to eq(:subquery)
    end

    it 'supports nested blocks' do
      CanCan.with_accessible_by_strategy(:left_join) do
        CanCan.with_accessible_by_strategy(:subquery) do
          expect(CanCan.accessible_by_strategy).to eq(:subquery)
        end
        expect(CanCan.accessible_by_strategy).to eq(:left_join)
      end

      expect(CanCan.accessible_by_strategy).to eq(:subquery)
    end

    it 'rejects unknown strategies' do
      expect { CanCan.with_accessible_by_strategy(:unknown) { nil } }.to raise_error(ArgumentError)
    end

    it 'accepts a subclass of CanCan::ModelAdapters::Strategies::Base' do
      strategy = Class.new(CanCan::ModelAdapters::Strategies::Base)

      strategy_in_block = CanCan.with_accessible_by_strategy(strategy) { CanCan.accessible_by_strategy }

      expect(strategy_in_block).to eq(strategy)
      expect(CanCan.accessible_by_strategy).to eq(:subquery)
    end

    it 'does not leak the override into other threads' do
      inside_block = Queue.new
      other_thread_done = Queue.new

      other_thread = Thread.new do
        inside_block.pop
        strategy = CanCan.accessible_by_strategy
        other_thread_done.push(:done)
        strategy
      end

      CanCan.with_accessible_by_strategy(:left_join) do
        inside_block.push(:go)
        other_thread_done.pop
      end

      expect(other_thread.value).to eq(:subquery)
    end

    it 'does not leak the override into other fibers' do
      strategy_in_other_fiber = CanCan.with_accessible_by_strategy(:left_join) do
        Fiber.new { CanCan.accessible_by_strategy }.resume
      end

      expect(strategy_in_other_fiber).to eq(:subquery)
    end
  end
end
