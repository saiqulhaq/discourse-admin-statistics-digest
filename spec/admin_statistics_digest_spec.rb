require_relative '../lib/admin_statistics_digest'

RSpec.describe AdminStatisticsDigest do
  describe '#generate' do
    it 'yields AdminStatisticsDigest::Report instance' do
      expect { |b|
        described_class.generate &b
      }.to yield_with_args(AdminStatisticsDigest::Report)
    end

    it 'returns AdminStatisticsDigest::Report instance' do
      expect(described_class.generate).to be_a(AdminStatisticsDigest::Report)
    end

    context 'populating data report' do
      subject(:report) do
        described_class.generate do
          active_user

          section do
            active_user
          end
        end
      end

      it 'fools' do
        expect(report.count).to eq(2)
      end
    end
  end
end
