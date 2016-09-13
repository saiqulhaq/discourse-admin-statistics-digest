require_relative '../../../spec/spec_helper'
require_relative '../../../lib/admin_statistics_digest/most_replied_topic'

RSpec.describe AdminStatisticsDigest::MostRepliedTopic do
  let(:report) { described_class.new }

  let!(:delete_all_topics) { Topic.delete_all }

  let!(:excluded_topic_1) do
    topics = []
    Timecop.freeze 2.months.ago do
      2.times { topics.push(create_topic) }
    end
    topics
  end

  let!(:excluded_topic_2) do
    topics = []
    2.times { topics.push(create_topic) }
    topics
  end

  let!(:topic_with_10_replies) do
    Timecop.freeze 1.month.ago do
      create_topic.tap do |t|
        10.times { create_post topic: t }
      end
    end
  end

  let!(:topic_with_5_replies) do
    Timecop.freeze 1.month.ago do
      create_topic.tap do |t|
        5.times { create_post topic: t }
      end
    end
  end

  let!(:topic_with_8_replies) do
    Timecop.freeze 1.month.ago do
      create_topic.tap do |t|
        8.times { create_post topic: t }
      end
    end
  end

  let!(:topic_with_2_replies) do
    Timecop.freeze 1.month.ago do
      create_topic.tap do |t|
        2.times { create_post topic: t }
      end
    end
  end

  describe 'setup' do
    it 'topic_with_10_replies' do
      expect(topic_with_10_replies.posts.count).to eq(10)
    end

    it 'topic_with_5_replies' do
      expect(topic_with_5_replies.posts.count).to eq(5)
    end

    it 'topic_with_8_replies' do
      expect(topic_with_8_replies.posts.count).to eq(8)
    end

    it 'topic_with_2_replies' do
      expect(topic_with_2_replies.posts.count).to eq(2)
    end
  end

  it 'returns SQL query to get most replied topics' do
    result = report.execute
    expect(result[:data].map {|p| p['id'].to_i }).to(
      match_array([
                    topic_with_10_replies.id,
                    topic_with_8_replies.id,
                    topic_with_5_replies.id,
                    topic_with_2_replies.id,
                    excluded_topic_1.map(&:id),
                    excluded_topic_2.map(&:id)
                  ].flatten))
  end

  it 'has :most_replied_by_month, and :limit filters' do
    expect(subject.available_filters).to match_array([:most_replied_by_month, :limit])
  end

  describe ':most_replied_by_month filter' do
    it 'filtering based on month' do
      report.filters do
        most_replied_by_month 1.month.ago
      end

      result = report.execute
      expect(result[:data].map {|p| p['id'].to_i }).to(
        match_array([
                    topic_with_10_replies.id,
                    topic_with_8_replies.id,
                    topic_with_5_replies.id,
                    topic_with_2_replies.id,
        ])
      )
    end
  end

  describe ':limit filter' do
    it 'limits the result' do
      report.filters do
        limit 3
      end

      result = report.execute
      expect(result[:data].map {|p| p['id'].to_i }).to(
        match_array([
                      topic_with_10_replies.id,
                      topic_with_8_replies.id,
                      topic_with_5_replies.id
                    ]))
    end
  end

end
