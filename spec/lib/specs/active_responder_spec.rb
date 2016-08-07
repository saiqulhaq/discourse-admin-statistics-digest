require_relative '../../spec_helper'

describe AdminStatisticsDigest::Specs::ActiveResponder do

  it "KEY store name is equals 'active_responder'" do
    expect(described_class::KEY).to eq('active_responder')
  end

  it "SPECS_PARAMETERS is equals 'reply_to_post_number', 'reads', 'like_score'" do
    expect(described_class::SPECS_PARAMETERS).to eq(['reply_to_post_number', 'reads', 'like_score'])
  end

end

