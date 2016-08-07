require_relative '../../spec_helper'

describe AdminStatisticsDigest::Specs::Store do
  subject (:store) { described_class.new('really!', ['awesome', 'discourse']) }

  it { is_expected.to respond_to(:data) }
  it { is_expected.to respond_to(:add) }
  it { is_expected.to respond_to(:remove) }

  describe '#data' do
    it 'returns empty array as default' do
      expect(store.data).to eq([])
    end

    it 'values is uniq' do
      store.add('awesome')
      expect(store.data).to eq(['awesome'])
      store.add('awesome')
      expect(store.data).to eq(['awesome'])
    end
  end

  describe '#add' do
    it 'adds a value to data if the value is valid' do
      store.add('foo')
      expect(store.data).to eq([])

      store.add('discourse')
      expect(store.data).to eq(['discourse'])
    end
  end

  describe '#remove' do
    it 'removes an existing value from data if the value is valid' do
      store.add('discourse')
      expect(store.data).to eq(['discourse'])
      store.remove('discourse')
      expect(store.data).to eq([])
    end
  end

end
