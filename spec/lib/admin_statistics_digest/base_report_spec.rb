require_relative '../../../spec/spec_helper'
require_relative '../../../lib/admin_statistics_digest/base_report'

RSpec.describe AdminStatisticsDigest::BaseReport do
  let(:report) { described_class.new }

  it '#to_sql will raise error if called' do
    expect { report.to_sql }.to raise_error(RuntimeError, 'Not implemented')
  end

  it '#execute returns has with "data" and "error" keys' do
    allow(report).to receive(:to_sql).and_return('')
    expect(report.execute).to include(:data, :error)
  end

  it '#available_filters default value is empty' do
    expect(report.available_filters).to be_empty
  end

  describe 'BaseReport#provide_filter' do
    it 'delegates defined filter to it self' do
      class Child < AdminStatisticsDigest::BaseReport
        provide_filter :limit
      end

      report = Child.new
      expect(report.available_filters).to include(:limit)
    end

    it 'raise error if given filter is undefined' do
      expect {
        class Child < AdminStatisticsDigest::BaseReport
          provide_filter :undefined_filter
        end
      }.to raise_error(NoMethodError, 'undefined_filter filter is unavailable')
    end
  end

end
