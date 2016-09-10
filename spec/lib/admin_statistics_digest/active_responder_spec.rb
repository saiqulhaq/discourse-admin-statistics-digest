require_relative '../../spec_helper'

RSpec.describe AdminStatisticsDigest::ActiveResponder do
  subject(:active_responder) { described_class.new }

  # setup responds
  let!(:admin) { Fabricate(:admin) }
  let!(:support_category) { Fabricate(:category, name: 'support', user: admin) }
  let!(:bug_category) { Fabricate(:category, name: 'bug', user: admin) }
  let!(:feature_category) { Fabricate(:category, name: 'feature', user: admin) }
  let!(:another_category) { Fabricate(:category, name: 'another', user: admin) }
  let!(:different_category) { Fabricate(:category, name: 'different', user: admin) }
  let!(:private_category) { Fabricate(:private_category, user: admin, group: Fabricate(:group)) }
  # end setup user

  let!(:delete_admin_posts) { admin.posts.each &:trash! } # remove default topic's post

  let!(:user_with_10_replies_to_support_and_bug_category_at_3_months_ago) do
    Fabricate(:user, name: 'user_with_10_replies_to_support_and_bug_category_at_3_months_ago').tap do |user|
      Timecop.freeze 3.months.ago do
        support_topic = Fabricate(:topic, category_id: support_category.id)
        bug_topic = Fabricate(:topic, category_id: bug_category.id)
        Fabricate.times(10, :post, user: user, topic: support_topic)
        Fabricate.times(10, :post, user: user, topic: bug_topic)
      end
    end
  end

  let!(:user_with_6_replies_to_support_and_bug_category_at_3_months_ago) do
    Fabricate(:user, name: 'user_with_6_replies_to_support_and_bug_category_at_3_months_ago').tap do |user|
      Timecop.freeze 3.months.ago do
        support_topic = Fabricate(:topic, category_id: support_category.id)
        bug_topic = Fabricate(:topic, category_id: bug_category.id)
        Fabricate.times(6, :post, user: user, topic: support_topic)
        Fabricate.times(6, :post, user: user, topic: bug_topic)
      end
    end
  end

  let!(:user_with_3_replies_to_support_and_bug_category_at_2_months_ago) do
    Fabricate(:user, name: 'user_with_3_replies_to_support_and_bug_category_at_2_months_ago').tap do |user|
      Timecop.freeze 2.months.ago do
        support_topic = Fabricate(:topic, category_id: support_category.id)
        bug_topic = Fabricate(:topic, category_id: bug_category.id)
        Fabricate.times(3, :post, user: user, topic: support_topic)
        Fabricate.times(3, :post, user: user, topic: bug_topic)
      end
    end
  end

  let!(:user_with_1_replies_to_support_and_bug_category_at_2_months_ago) do
    Fabricate(:user, name: 'user_with_1_replies_to_support_and_bug_category_at_2_months_ago').tap do |user|
      Timecop.freeze 2.months.ago do
        support_topic = Fabricate(:topic, category_id: support_category.id)
        bug_topic = Fabricate(:topic, category_id: bug_category.id)
        Fabricate(:post, user: user, topic: support_topic)
        Fabricate(:post, user: user, topic: bug_topic)
      end
    end
  end

  let!(:user_with_10_replies_to_feature_category_at_3_months_ago) do
    feature_topic = Fabricate(:topic, category_id: feature_category.id)
    Fabricate(:user, name: 'user_with_10_replies_to_feature_category_at_3_months_ago').tap do |user|
      Timecop.freeze 3.months.ago do
        Fabricate.times(10, :post, user: user, topic: feature_topic)
      end
    end
  end

  let!(:user_with_11_replies_to_feature_category_at_2_months_ago) do
    feature_topic = Fabricate(:topic, category_id: feature_category.id)
    Fabricate(:user, name: 'user_with_11_replies_to_feature_category_at_2_months_ago').tap do |user|
      Timecop.freeze 2.months.ago do
        Fabricate.times(11, :post, user: user, topic: feature_topic)
      end
    end
  end


  let!(:user_with_12_replies_to_feature_category_at_1_month_ago) do
    feature_topic = Fabricate(:topic, category_id: feature_category.id)
    Fabricate(:user, name: 'user_with_12_replies_to_feature_category_at_1_month_ago').tap do |user|
      Timecop.freeze 1.months.ago do
        Fabricate.times(12, :post, user: user, topic: feature_topic)
      end
    end
  end

  let!(:user_with_6_replies_to_feature_category_at_1_month_ago) do
    feature_topic = Fabricate(:topic, category_id: feature_category.id)
    Fabricate(:user, name: 'user_with_6_replies_to_feature_category_at_1_month_ago').tap do |user|
      Timecop.freeze 1.months.ago do
        Fabricate.times(6, :post, user: user, topic: feature_topic)
      end
    end
  end

  it 'returns empty array if category id is not defined' do
    result = subject.execute
    expect(result[:error]).to be_nil
    expect(result[:data]).to match_array([])
  end

  it 'exclude trashed post' do
    category = support_category

    subject.filters do
      topic_category_id category.id
    end

    result = subject.execute

    expect(result[:error]).to be_nil
    expect(result[:data].map {|d| d['user_id'].to_i}).to(
      match_array([
                    user_with_10_replies_to_support_and_bug_category_at_3_months_ago.id,
                    user_with_6_replies_to_support_and_bug_category_at_3_months_ago.id,
                    user_with_3_replies_to_support_and_bug_category_at_2_months_ago.id,
                    user_with_1_replies_to_support_and_bug_category_at_2_months_ago.id
                  ])
    )

    user_with_10_replies_to_support_and_bug_category_at_3_months_ago.posts.take(5).each &:trash!

    result = subject.execute

    expect(result[:error]).to be_nil
    expect(result[:data].map {|d| d['user_id'].to_i}).to(
      match_array([
                    user_with_6_replies_to_support_and_bug_category_at_3_months_ago.id,
                    user_with_10_replies_to_support_and_bug_category_at_3_months_ago.id, # this user only has 5 posts
                    user_with_3_replies_to_support_and_bug_category_at_2_months_ago.id,
                    user_with_1_replies_to_support_and_bug_category_at_2_months_ago.id
                  ])
    )
  end

  describe 'filter' do
    describe 'active_range filter' do
      before do
        category = feature_category
        subject.filters do
          between 2.months.ago..Date.today
          topic_category_id category.id
        end
      end

      it 'filters users based on activity of given date' do
        result = subject.execute
        expect(result[:error]).to be_nil
        expect(result[:data].map {|d| d['user_id'].to_i }).to(
          match_array([
                        user_with_12_replies_to_feature_category_at_1_month_ago.id,
                        user_with_11_replies_to_feature_category_at_2_months_ago.id,
                        user_with_6_replies_to_feature_category_at_1_month_ago.id
                      ])
        )
      end

    end

    describe 'limit filter' do
      it 'limits the result' do
        category = bug_category

        subject.filters do
          topic_category_id category.id
          limit 2
        end
        result = subject.execute

        expect(result[:error]).to be_nil
        expect(result[:data].map {|d| d['user_id'].to_i}).to(
          match_array([
                        user_with_10_replies_to_support_and_bug_category_at_3_months_ago.id,
                        user_with_6_replies_to_support_and_bug_category_at_3_months_ago.id,
                      ])
        )
      end
    end

  end

end
