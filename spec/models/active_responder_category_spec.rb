require_relative '../spec_helper'
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

    describe '#update_categories' do
      it 'updates selected categories' do
        expect(categories.length).to eq(3)

        selected_categories = categories.last(2).map &:id
        described_class.update_categories(selected_categories)
        selected_categories.each do |c|
          expect(described_class.find(c).selected).to be_truthy
        end
        expect(described_class.find(categories.first.id).selected).to be_falsey
      end
    end
  end
end
