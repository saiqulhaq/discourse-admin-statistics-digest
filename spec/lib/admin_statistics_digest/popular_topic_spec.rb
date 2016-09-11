require_relative '../../../spec/spec_helper'
require_relative '../../../lib/admin_statistics_digest/popular_topic'

RSpec.describe AdminStatisticsDigest::PopularTopic do
  let(:popular_topic) { described_class.new }

  let(:users) { Fabricate.times(3, :user) }
  let!(:topic_score_10) do
    Timecop.freeze 1.month.ago.end_of_month do

      Timecop.freeze 20.days.ago do
        @topic_1 = create_topic user: users.sample
        3.times { create_post topic: @topic_1, user_id: users.sample.id }
      end

      Timecop.freeze 10.days.ago do
        3.times { create_post topic: @topic_1, user: users.sample }
      end

      Timecop.freeze 5.days.ago do
        3.times { create_post topic: @topic_1, user_id: users.sample.id }
      end

      Timecop.freeze 2.days.ago do
        1.times { create_post topic: @topic_1, user_id: users.sample.id }
      end
    end

    @topic_1.first_post.update_attribute :like_count, 10
    @topic_1.update_attributes views: 10, like_count: 10, posts_count: @topic_1.posts.count
    @topic_1
  end

  let!(:topic_score_8) do
    Timecop.freeze 1.month.ago.end_of_month do

      Timecop.freeze 20.days.ago do
        @topic_2 = create_topic user: users.sample
        2.times { create_post topic: @topic_2, user_id: users.sample.id }
      end

      Timecop.freeze 10.days.ago do
        2.times { create_post topic: @topic_2, user: users.sample }
      end

      Timecop.freeze 5.days.ago do
        2.times { create_post topic: @topic_2, user_id: users.sample.id }
      end

      Timecop.freeze 2.days.ago do
        2.times { create_post topic: @topic_2, user_id: users.sample.id }
      end
    end

    @topic_2.first_post.update_attribute :like_count, 8
    @topic_2.update_attributes views: 8, like_count: 8, posts_count: @topic_2.posts.count
    @topic_2
  end

  let!(:topic_score_12) do
    Timecop.freeze 1.month.ago.end_of_month do

      Timecop.freeze 20.days.ago do
        @topic_3 = create_topic user: users.sample
        3.times { create_post topic: @topic_3, user_id: users.sample.id }
      end

      Timecop.freeze 10.days.ago do
        3.times { create_post topic: @topic_3, user: users.sample }
      end

      Timecop.freeze 5.days.ago do
        3.times { create_post topic: @topic_3, user_id: users.sample.id }
      end

      Timecop.freeze 2.days.ago do
        3.times { create_post topic: @topic_3, user_id: users.sample.id }
      end
    end

    @topic_3.first_post.update_attribute :like_count, 12
    @topic_3.update_attributes views: 12, like_count: 12, posts_count: @topic_3.posts.count
    @topic_3
  end

  let!(:topic_score_4) do
    Timecop.freeze 1.month.ago.end_of_month do

      Timecop.freeze 20.days.ago do
        @topic_4 = create_topic user: users.sample
        create_post topic: @topic_4, user_id: users.sample.id
      end

      Timecop.freeze 10.days.ago do
        create_post topic: @topic_4, user: users.sample
      end

      Timecop.freeze 5.days.ago do
        create_post topic: @topic_4, user_id: users.sample.id
      end

      Timecop.freeze 2.days.ago do
        create_post topic: @topic_4, user_id: users.sample.id
      end
    end

    @topic_4.first_post.update_attribute :like_count, 4
    @topic_4.update_attributes views: 4, like_count: 4, posts_count: @topic_4.posts.count
    @topic_4
  end

  let!(:topic_score_5) do
    Timecop.freeze 1.month.ago.end_of_month do

      Timecop.freeze 20.days.ago do
        @topic_5 = create_topic user: users.sample
        2.times { create_post topic: @topic_5, user_id: users.sample.id }
      end

      Timecop.freeze 10.days.ago do
        2.times { create_post topic: @topic_5, user: users.sample }
      end

      Timecop.freeze 5.days.ago do
        create_post topic: @topic_5, user_id: users.sample.id
      end
    end

    @topic_5.first_post.update_attribute :like_count, 5
    @topic_5.update_attributes views: 5, like_count: 5, posts_count: @topic_5.posts.count
    @topic_5
  end

  let!(:excluded_topic_with_score_15) do
    Timecop.freeze 2.month.ago.end_of_month do

      Timecop.freeze 20.days.ago do
        @topic_6 = create_topic user: users.sample
        5.times { create_post topic: @topic_6, user_id: users.sample.id }
      end

      Timecop.freeze 10.days.ago do
        5.times { create_post topic: @topic_6, user: users.sample }
      end

      Timecop.freeze 17.days.ago do
        5.times { create_post topic: @topic_6, user: users.sample }
      end

    end

    @topic_6.first_post.update_attribute :like_count, 15
    @topic_6.update_attributes views: 15, like_count: 15, posts_count: @topic_6.posts.count
    @topic_6
  end

  let!(:excluded_topic_with_score_18) do
    Timecop.freeze Date.today.end_of_month do

      Timecop.freeze 20.days.ago do
        @topic_7 = create_topic user: users.sample
        5.times { create_post topic: @topic_7, user_id: users.sample.id }
      end

      Timecop.freeze 10.days.ago do
        5.times { create_post topic: @topic_7, user: users.sample }
      end

      Timecop.freeze 17.days.ago do
        3.times { create_post topic: @topic_7, user: users.sample }
      end

      Timecop.freeze 5.days.ago do
        5.times { create_post topic: @topic_7, user_id: users.sample.id }
      end
    end

    @topic_7.first_post.update_attribute :like_count, 18
    @topic_7.update_attributes views: 18, like_count: 18, posts_count: @topic_7.posts.count
    @topic_7
  end

  describe 'test_fixtures' do
    it 'topic_score_10 should be correct' do
      expect(topic_score_10.views).to eq(10)
      expect(topic_score_10.posts_count).to eq(10)
      expect(topic_score_10.like_count).to eq(10)
      expect(topic_score_10.first_post.like_count).to eq(10)
    end

    it 'topic_score_8 should be correct' do
      expect(topic_score_8.views).to eq(8)
      expect(topic_score_8.posts_count).to eq(8)
      expect(topic_score_8.like_count).to eq(8)
      expect(topic_score_8.first_post.like_count).to eq(8)
    end

    it 'topic_score_12 should be correct' do
      expect(topic_score_12.views).to eq(12)
      expect(topic_score_12.posts_count).to eq(12)
      expect(topic_score_12.like_count).to eq(12)
      expect(topic_score_12.first_post.like_count).to eq(12)
    end

    it 'topic_score_4 should be correct' do
      expect(topic_score_4.views).to eq(4)
      expect(topic_score_4.posts_count).to eq(4)
      expect(topic_score_4.like_count).to eq(4)
      expect(topic_score_4.first_post.like_count).to eq(4)
    end

    it 'topic_score_5 should be correct' do
      expect(topic_score_5.views).to eq(5)
      expect(topic_score_5.posts_count).to eq(5)
      expect(topic_score_5.like_count).to eq(5)
      expect(topic_score_5.first_post.like_count).to eq(5)
    end

    it 'excluded_topic_with_score_15 should be correct' do
      expect(excluded_topic_with_score_15.views).to eq(15)
      expect(excluded_topic_with_score_15.posts_count).to eq(15)
      expect(excluded_topic_with_score_15.like_count).to eq(15)
      expect(excluded_topic_with_score_15.first_post.like_count).to eq(15)
    end

    it 'excluded_topic_with_score_18 should be correct' do
      expect(excluded_topic_with_score_18.views).to eq(18)
      expect(excluded_topic_with_score_18.posts_count).to eq(18)
      expect(excluded_topic_with_score_18.like_count).to eq(18)
      expect(excluded_topic_with_score_18.first_post.like_count).to eq(18)
    end
  end

  it 'generate top topic when initialized' do
    expect(TopTopic.count).to eq(0)
    described_class.new
    expect(TopTopic.count).to_not eq(0)
  end

  it 'returns popular topic at last month by default' do
    result = popular_topic.execute
    expect(result[:data].map {|d| d['topic_id'].to_i }).to(
      match_array([
        topic_score_12.id,
        topic_score_10.id,
        topic_score_8.id,
        topic_score_5.id,
        topic_score_4.id
      ])
    )
  end

end
