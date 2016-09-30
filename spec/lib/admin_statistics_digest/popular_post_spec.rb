require_relative '../../spec_helper'
require_relative './../../../lib/admin_statistics_digest/popular_post.rb'

RSpec.describe AdminStatisticsDigest::PopularPost do

  let!(:user) { Fabricate.create(:user) }
  let!(:topic) { Timecop.freeze(3.month.ago) { Fabricate.create(:topic, user: user) } }

  # First post is excluded
  let!(:first_post) { topic.posts << create_post(title: 'This is valid title, yeah correct') }

  let!(:post_rank_100_at_1_month_ago) do
    Timecop.freeze(1.month.ago) do
      create_post(topic: topic, user: user)
    end
  end

  let!(:post_rank_200_at_1_month_ago) do
    Timecop.freeze(1.month.ago) do
      create_post(topic: topic, user: user)
    end
  end

  let!(:post_rank_40_at_1_month_ago) do
    Timecop.freeze(1.month.ago) { create_post(topic: topic, user: user) }
  end

  let!(:post_rank_15_at_1_month_ago) do
    Timecop.freeze(1.month.ago) { create_post(topic: topic, user: user) }
  end

  let!(:post_rank_10_at_2_month_ago) do
    Timecop.freeze(2.month.ago) { create_post(topic: topic, user: user) }
  end

  let!(:post_rank_20_at_2_month_ago) do
    Timecop.freeze(2.month.ago) { create_post(topic: topic, user: user) }
  end

  let!(:post_rank_300_at_3_month_ago) do
    Timecop.freeze(3.month.ago) { create_post(topic: topic, user: user) }
  end

  let!(:post_rank_5_at_this_month) do
    create_post(topic: topic, user: user)
  end

  let!(:post_rank_70_at_this_month) do
    create_post(topic: topic, user: user)
  end

  def update_rank
    self.methods.select do |m|
      m.to_s.include?('post_rank_')
    end.each do |post|
      post.to_s.match /rank_(\d*)_/
      rank = $1.to_i.to_f
      post = self.send post
      Post.exec_sql("UPDATE #{Post.table_name} SET percent_rank = #{rank} WHERE id = #{post.id}")
      post.reload
    end
  end

  let!(:update_rank!) { update_rank }

  it 'has :limit, :popular_by_date and :popular_by_month filters' do
    expect(subject.available_filters).to match_array([:limit, :popular_by_month, :popular_by_date])
  end

  describe '#execute' do
    it 'returns all posts sorted by percent_rank' do
      result = subject.execute

      update_rank
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

        update_rank
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

        update_rank
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
