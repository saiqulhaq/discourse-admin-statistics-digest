require_relative '../../spec/spec_helper'
require_relative '../../lib/admin_statistics_digest/liked_post'

RSpec.describe AdminStatisticsDigest::LikedPost do
  before { Post.delete_all }
  let(:user) { User.last || Fabricate.create(:user) }
  let(:topic) { Topic.last || Fabricate.create(:topic) }
  let!(:p1) { create_post(like_count: 100, user: user, topic: topic) }
  let!(:p2) { create_post(like_count: 50, user: user, topic: topic) }
  let!(:p3) { create_post(like_count: 150, user: user, topic: topic) }
  let!(:p4) { create_post(like_count: 30, user: user, topic: topic) }
  let!(:p5) { create_post(like_count: 5, user: user, topic: topic) }

  it 'get all posts and ordered the results by like' do
    posts = described_class.new
    result = exec_sql(posts.to_sql)
    expect(result.map {|p| p['id'].to_i }).to match_array([p3.id, p1.id, p2.id, p4.id, p5.id])
  end

end
