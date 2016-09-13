require_relative './../../../lib/admin_statistics_digest/popular_post.rb'

RSpec.describe AdminStatisticsDigest::PopularPost do
  def update_rank(post, rank)
    post.update_column(:percent_rank, rank)
    post
  end
  let(:topic) { Timecop.freeze(3.month.ago) { create_topic } }
  let(:user) { topic.user }

  # First post is excluded
  let!(:first_post) { topic.posts << create_post }

  let!(:post_rank_100_at_1_month_ago) do
    Timecop.freeze(1.month.ago) do
      update_rank(create_post(topic: topic, user: user), 100)
    end
  end

  let!(:post_rank_200_at_1_month_ago) do
    Timecop.freeze(1.month.ago) do
      update_rank(create_post(topic: topic, user: user), 200)
    end
  end

  let!(:post_rank_40_at_1_month_ago) do
    Timecop.freeze(1.month.ago) { update_rank(create_post(topic: topic, user: user), 40) }
  end

  let!(:post_rank_15_at_1_month_ago) do
    Timecop.freeze(1.month.ago) { update_rank(create_post(topic: topic, user: user), 15) }
  end

  let!(:post_rank_10_at_2_month_ago) do
    Timecop.freeze(2.month.ago) { update_rank(create_post(topic: topic, user: user), 10) }
  end

  let!(:post_rank_20_at_2_month_ago) do
    Timecop.freeze(2.month.ago) { update_rank(create_post(topic: topic, user: user), 20) }
  end

  let!(:post_rank_300_at_3_month_ago) do
    Timecop.freeze(3.month.ago) { update_rank(create_post(topic: topic, user: user), 300) }
  end

  let!(:post_rank_5_at_this_month) do
    update_rank(create_post(topic: topic, user: user), 5)
  end

  let!(:post_rank_70_at_this_month) do
    update_rank(create_post(topic: topic, user: user), 70)
  end

  it 'has :limit, and :popular_by_month filters' do
    expect(subject.available_filters).to match_array([:limit, :popular_by_month])
  end

  describe '#execute' do
    it 'returns all posts sorted by percent_rank' do
      result = subject.execute
      expect(result[:data].map {|d| d['id'].to_i }).to(
        match_array([
          post_rank_300_at_3_month_ago.id,
          post_rank_200_at_1_month_ago.id,
          post_rank_100_at_1_month_ago.id,
          post_rank_70_at_this_month.id,
          post_rank_40_at_1_month_ago.id,
          post_rank_20_at_2_month_ago.id,
          post_rank_15_at_1_month_ago.id,
          post_rank_10_at_2_month_ago.id,
          post_rank_5_at_this_month.id
        ])
      )
    end
  end

  describe '#filters' do

    describe '#limit' do
      it 'limits the result' do
        subject.filters do
          limit 3
        end

        result = subject.execute
        expect(result[:data].map {|d| d['id'].to_i }).to(
          match_array([
            post_rank_300_at_3_month_ago.id,
            post_rank_200_at_1_month_ago.id,
            post_rank_100_at_1_month_ago.id
          ])
        )
      end
    end

    describe '#popular_by_month' do
      it 'filters post based on creation date' do
        subject.filters do
          popular_by_month 1.month.ago
        end

        result = subject.execute

        expect(result[:data].map {|d| d['id'].to_i }).to(
          match_array([
            post_rank_200_at_1_month_ago.id,
            post_rank_100_at_1_month_ago.id,
            post_rank_15_at_1_month_ago.id,
            post_rank_40_at_1_month_ago.id
          ])
        )
      end
    end

  end

end
