# frozen_string_literal: true

require 'spec_helper'

describe 'be_able_to' do
  subject { double }

  context 'when expecting to match' do
    context 'check single ability' do
      it 'delegates to can?' do
        is_expected.to receive(:can?).with(:read, 123) { true }

        result = be_able_to([:read], 123).matches?(subject)
        expect(result).to eq(true)
      end

      it 'reports a nice failure message' do
        is_expected.to receive(:can?).with(:read, 123) { false }

        expect do
          is_expected.to be_able_to(:read, 123)
        end.to raise_error('expected to be able to :read 123')
      end

      it 'delegates additional arguments to can? and reports a failure message' do
        is_expected.to receive(:can?).with(:read, 123, 456) { false }

        expect do
          is_expected.to be_able_to(:read, 123, 456)
        end.to raise_error('expected to be able to :read 123 456')
      end
    end

    context 'check array of abilities' do
      it 'delegates to can? with array of abilities with one action' do
        is_expected.to receive(:can?).with(:read, 123) { true }

        result = be_able_to([:read], 123).matches?(subject)
        expect(result).to eq(true)
      end

      it 'delegates to can? with array of abilities with multiple actions' do
        is_expected.to receive(:can?).with(:read, 123) { true }
        is_expected.to receive(:can?).with(:update, 123) { true }

        result = be_able_to(%i[read update], 123).matches?(subject)
        expect(result).to eq(true)
      end

      it 'does not delegate to can? with empty array of abilities' do
        is_expected.not_to receive(:can?)

        result = be_able_to([], 123).matches?(subject)
        expect(result).to eq(false)
      end

      it 'delegates to can? with array of abilities with only one eligable ability' do
        is_expected.to receive(:can?).with(:read, 123) { true }
        is_expected.to receive(:can?).with(:update, 123) { false }

        result = be_able_to(%i[read update], 123).matches?(subject)
        expect(result).to eq(false)
      end
    end
  end

  context 'when expecting not to match' do
    context 'check single ability' do
      it 'delegates to cannot?' do
        is_expected.to receive(:cannot?).with(:read, 123) { true }

        result = be_able_to([:read], 123).does_not_match?(subject)
        expect(result).to eq(true)
      end

      it 'reports a nice failure message' do
        is_expected.to receive(:cannot?).with(:read, 123) { false }

        expect do
          is_expected.not_to be_able_to(:read, 123)
        end.to raise_error('expected not to be able to :read 123')
      end

      it 'delegates additional arguments to can? and reports a failure message' do
        is_expected.to receive(:cannot?).with(:read, 123, 456) { false }

        expect do
          is_expected.not_to be_able_to(:read, 123, 456)
        end.to raise_error('expected not to be able to :read 123 456')
      end
    end

    context 'check array of abilities' do
      it 'delegates to cannot? with array of abilities with one action' do
        is_expected.to receive(:cannot?).with(:read, 123) { true }

        result = be_able_to([:read], 123).does_not_match?(subject)
        expect(result).to eq(true)
      end

      it 'delegates to cannot? with array of abilities with multiple actions' do
        is_expected.to receive(:cannot?).with(:read, 123) { true }
        is_expected.to receive(:cannot?).with(:update, 123) { true }

        result = be_able_to(%i[read update], 123).does_not_match?(subject)
        expect(result).to eq(true)
      end

      it 'does not delegate to cannot? with empty array of abilities' do
        is_expected.not_to receive(:cannot?)

        result = be_able_to([], 123).does_not_match?(subject)
        expect(result).to eq(false)
      end

      it 'delegates to cannot? with array of abilities with only one ineligable ability' do
        is_expected.to receive(:cannot?).with(:read, 123) { false }
        is_expected.to receive(:cannot?).with(:update, 123) { true }

        result = be_able_to(%i[update read], 123).does_not_match?(subject)
        expect(result).to eq(false)
      end
    end
  end
end
