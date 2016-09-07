require_relative '../../../spec/spec_helper'
require_relative '../../../lib/admin_statistics_digest/liked_post'

RSpec.describe AdminStatisticsDigest::LikedPost do
  let(:report) { described_class.new }

  before(:all) { Post.delete_all }

  Timecop.freeze 1.year.ago do
    let(:user) { User.last || Fabricate.create(:user) }
    let(:topic) { Topic.last || Fabricate.create(:topic) }
  end

  let!(:post_at_1_month_ago) do
    Timecop.freeze 1.month.ago do
      create_post(user: user, topic: topic).tap {|p| p.update_column(:like_count, 100) }
    end
  end

  let!(:post_at_2_month_ago) do
    Timecop.freeze 2.months.ago do
      create_post(user: user, topic: topic).tap {|p| p.update_column(:like_count, 50) }
    end
  end

  let!(:post_at_3_month_ago) do
    Timecop.freeze 3.months.ago do
      create_post(user: user, topic: topic).tap {|p| p.update_column(:like_count, 150) }
    end
  end

  let!(:post_at_4_month_ago) do
    Timecop.freeze 4.months.ago do
      create_post(user: user, topic: topic).tap {|p| p.update_column(:like_count, 30) }
    end
  end

  let!(:post_at_5_month_ago) do
    Timecop.freeze 5.months.ago do
      create_post(user: user, topic: topic).tap {|p| p.update_column(:like_count, 5) }
    end
  end


  describe '#to_sql' do

    it 'returns SQL query to get all posts and ordered the results by counting "post.like" ' do
      result = exec_sql(report.to_sql)
      expect(result.map {|p| p['id'].to_i }).to(
        match_array([
                      post_at_3_month_ago.id,
                      post_at_1_month_ago.id,
                      post_at_2_month_ago.id,
                      post_at_4_month_ago.id,
                      post_at_5_month_ago.id
                    ]))
    end
  end

  it 'has :between, and :limit filters' do
    expect(subject.available_filters).to match_array([:between, :limit])
  end

  describe ':between filter' do
    it 'filtering post#created_at' do
      report.filters do
        between 3.months.ago..2.months.ago
      end

      result = exec_sql(report.to_sql)
      expect(result.map {|p| p['id'].to_i }).to(
        match_array([
                      post_at_3_month_ago.id,
                      post_at_2_month_ago.id
                    ]))
    end
  end

  describe ':limit filter' do
    it 'limits the result' do
      report.filters do
        limit 3
      end

      result = exec_sql(report.to_sql)
      expect(result.map {|p| p['id'].to_i }).to(
        match_array([
                      post_at_3_month_ago.id,
                      post_at_2_month_ago.id,
                      post_at_1_month_ago.id
                    ]))
    end
  end

end
