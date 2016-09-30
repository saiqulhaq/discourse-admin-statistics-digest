require_relative '../../spec_helper'
require_relative '../../../lib/admin_statistics_digest/report'

RSpec.describe AdminStatisticsDigest::Report do

  describe '#generate' do
    it 'yields AdminStatisticsDigest::Report instance' do
      expect { |b|
        described_class.generate &b
      }.to yield_with_args(described_class)
    end

    it 'returns AdminStatisticsDigest::Report instance' do
      expect(described_class.generate).to be_a(described_class)
    end
  end

end
