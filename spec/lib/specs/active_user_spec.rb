require_relative '../../spec_helper'

describe AdminStatisticsDigest::Specs::ActiveUser do

  it "KEY store name is equals 'active_user'" do
    expect(described_class::KEY).to eq('active_user')
  end

end

