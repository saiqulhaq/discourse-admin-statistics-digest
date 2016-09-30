require_relative '../../spec_helper'
require_relative '../../../lib/admin_statistics_digest/parse_to_cron_hash'

RSpec.describe AdminStatisticsDigest::ParseToCronHash do

  describe '#parse' do
    context 'min parameter' do

      it 'returns true if min value is between 0-59, hour value is between 0-23, and day value is between 1-30' do
        result = described_class.parse(0, 0, 1)
        expect(result.valid?).to be_truthy

        result = described_class.parse(59, 23, 30)
        expect(result.valid?).to be_truthy

        result = described_class.parse(-1, 0, 1)
        expect(result.valid?).to be_falsey
        expect(result.message).to eq('Invalid minute')

        result = described_class.parse(0, -1, 1)
        expect(result.valid?).to be_falsey
        expect(result.message).to eq('Invalid hour')

        result = described_class.parse(0, 0, 0)
        expect(result.valid?).to be_falsey
        expect(result.message).to eq('Invalid day')

        result = described_class.parse(60, 23, 30)
        expect(result.valid?).to be_falsey
        expect(result.message).to eq('Invalid minute')

        result = described_class.parse(59, 24, 30)
        expect(result.valid?).to be_falsey
        expect(result.message).to eq('Invalid hour')

        result = described_class.parse(59, 23, 31)
        expect(result.valid?).to be_falsey
        expect(result.message).to eq('Invalid day')
      end

      it 'returns valid cron hash when argument is valid' do
        result = described_class.parse(0, 0, 1)
        expect(result.valid?).to be_truthy
        expect(result.cron_hash).to eq('0 0 1 * *') # tested on http://cron.schlitt.info/
      end
    end
  end
end
