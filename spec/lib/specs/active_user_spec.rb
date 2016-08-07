require_relative '../../spec_helper'

describe AdminStatisticsDigest::Specs::ActiveUser do

  it "KEY store name is equals 'active_user'" do
    expect(described_class::KEY).to eq('active_user')
  end

  it "SPECS_PARAMETERS is equals 'like received', 'like given', 'topics', 'replies', 'viewed', 'read', 'visits'" do
    expect(described_class::SPECS_PARAMETERS).to eq(['like received', 'like given', 'topics', 'replies', 'viewed', 'read', 'visits'])
  end

  describe '#to_sql' do
    let (:instance) { described_class.new }
    it 'accepts :signed_up_from parameter optionally' do
      expect {
        instance.to_sql signed_up_from: 1.month.ago
      }.not_to raise_error
    end

    it 'accepts :signed_up_between parameter optionally' do
      expect {
        instance.to_sql signed_up_between: 3.month.ago...1.month.ago
      }.not_to raise_error
    end

    it 'raises ArgumentError when :signed_up_from and :signed_up_between given in the same time' do
      expect {
        instance.to_sql(signed_up_between: 3.month.ago...1.month.ago, signed_up_from: 1.month.ago)
      }.to raise_error(ArgumentError)
    end

    it 'raise ArgumentError if :signed_up_from is not Date or Time instance' do
      expect { instance.to_sql signed_up_from: 'today' }.to raise_error(ArgumentError)
      expect { instance.to_sql signed_up_from: Date.today }.not_to raise_error
    end

    it 'raise ArgumentError if :signed_up_between is not Range instance' do
      expect { instance.to_sql signed_up_between: 'today' }.to raise_error(ArgumentError)
      expect { instance.to_sql signed_up_between: Date.today }.to raise_error(ArgumentError)
      expect {
        instance.to_sql signed_up_between: 1.week.ago...Date.today
      }.not_to raise_error
    end

    it 'accepts :specs argument to specify active specification' do
      expect { instance.to_sql specs: [] }.not_to raise_error
    end
  end
end

