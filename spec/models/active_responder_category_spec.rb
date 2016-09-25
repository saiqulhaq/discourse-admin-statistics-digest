require 'rails_helper'
require_relative '../../app/models/active_responder_category'

RSpec.describe AdminStatisticsDigest::ActiveResponderCategory do
  before(:all) { Category.delete_all }

  let!(:categories) { Fabricate.times(3, :category) }

  context 'Class Methods' do
    describe '#all' do
      it 'returns all categories' do
        expect(described_class.all.length).to eq(categories.length)
      end

      it 'initialize selected keys = false as default' do
        described_class.all.each do |c|
          expect(c.selected).to be_falsey
        end
      end
    end

    describe '#toggle_selection' do
      it 'inverse the .selected value of an item category' do
        category = described_class.find(categories.last.id)
        expect(category.selected).to be_falsey

        described_class.toggle_selection(category.id)
        category = described_class.find(category.id)
        expect(category.selected).to be_truthy

        described_class.toggle_selection(category.id)
        category = described_class.find(category.id)
        expect(category.selected).to be_falsey
      end
    end
  end
end
