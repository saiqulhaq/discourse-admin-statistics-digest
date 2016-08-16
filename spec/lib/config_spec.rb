require_relative '../spec_helper'

describe AdminStatisticsDigest::Config do

  describe '#mail_out_interval' do
    it 'default value is 30 days' do
      expect(described_class.mail_out_interval).to eq(30.days)
    end

    it 'can be modified' do
      described_class.mail_out_interval = 5.days
      expect(described_class.mail_out_interval).to eq(5.days)
    end
  end

end

