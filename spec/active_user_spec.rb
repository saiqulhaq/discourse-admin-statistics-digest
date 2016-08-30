require_relative './spec_helper'

RSpec.describe AdminStatisticsDigest::ActiveUser do

  # setup user
  Given!(:user_with_5_topics_and_5_posts) do
    user = Fabricate.create(:user)
    5.times do
      topic = create_topic(user: user)
      create_post(user: user, topic: topic)
    end
    user
  end

  Given!(:user_with_3_topics_and_3_posts) do
    user = Fabricate.create(:user)
    3.times do
      topic = create_topic(user: user)
      create_post(user: user, topic: topic)
    end
    user
  end

  Given!(:user_with_10_posts) do
    user = Fabricate.create(:user)
    topic = Topic.last
    10.times { create_post(user: user, topic: topic) }
    user
  end


  Given!(:user_with_8_posts) do
    user = Fabricate.create(:user)
    topic = Topic.last
    8.times { create_post(user: user, topic: topic) }
    user
  end

  Given!(:user_with_12_topics) do
    user = Fabricate.create(:user)
    12.times { create_topic(user: user) }
    user
  end

  Given!(:user_with_3_topics) do
    user = Fabricate.create(:user)
    3.times { create_topic(user: user) }
    user
  end

  Given!(:admin_with_4_topics) do
    admin = Fabricate.create(:user, admin: true)
    4.times { create_topic(user: admin) }
    admin
  end

  Given!(:moderator_with_7_topics) do
    moderator = Fabricate.create(:user, moderator: true)
    7.times { create_topic(user: moderator) }
    moderator
  end

  Then do
    expect(User.where('admin = false AND moderator = false').length).to eq(6)
    expect(User.staff.where('id != ?', Discourse::SYSTEM_USER_ID).length).to eq(2)
  end
  # end setup user

  context 'include_staff filter' do

    context 'value is true' do
      Given! :active_user do
        active_user = described_class.build do
          include_staff
        end
      end

      Then do
        result = active_user.execute
        expect(result[:data].size).to eq(8)
      end

      context 'Set limit filter' do
        Given do
          active_user.filters[:limit] = 3
        end

        Then do
          result = active_user.execute
          expect(result[:data].size).to eq(3)
        end
      end
    end

    context 'value is false' do
      Given! :result do
        active_user = described_class.new do
          include_staff false
        end
        active_user.execute
      end

      Then do
        expect(result[:data].size).to eq(6)
      end
    end

    context 'include_staff filter is empty' do
      Given! :result do
        described_class.new.execute
      end

      Then do
        expect(result[:data].size).to eq(6)
      end
    end

  end
end
