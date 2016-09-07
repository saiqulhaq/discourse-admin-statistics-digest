# require 'fabrication'
# require 'timecop'

RateLimiter.disable
#
# def next_seq
#   @next_seq = (@next_seq || 0) + 1
# end
#
# ########################### ACTIVE USER ########################################
# # Timecop.freeze 80.days.ago do
# #   user = Fabricate.create(:user, name: 'user_with_5_topics_and_5_posts_at_80_days_ago')
# #   5.times do
# #     topic = Fabricate :topic, user: user
# #     Fabricate(:post_with_long_raw_content, user: user, topic: topic)
# #   end
# # end
# #
# # Timecop.freeze 25.days.ago do
# #   user = Fabricate.create(:user, name: 'user_with_5_topics_and_5_posts_at_25_days_ago')
# #   5.times do
# #     topic = Fabricate :topic, user: user
# #     Fabricate(:post_with_long_raw_content, user: user, topic: topic)
# #   end
# # end
# #
# #
# # Timecop.freeze 50.days.ago do
# #   user = Fabricate.create(:user, name: 'user_with_3_topics_and_3_posts_at_50_days_ago')
# #   3.times do
# #     topic = Fabricate :topic, user: user
# #     Fabricate(:post_with_long_raw_content, user: user, topic: topic)
# #   end
# # end
# #
# # topic = Topic.last
# # Timecop.freeze 10.days.ago do
# #   user = Fabricate.create(:user, name: 'user_with_10_posts_at_10_days_ago')
# #   10.times { Fabricate(:post_with_long_raw_content, user: user, topic: topic )}
# # end
# #
# #
# # topic = Topic.last
# # Timecop.freeze 5.days.ago do
# #   user = Fabricate.create(:user, name: 'user_with_8_posts_at_5_days_ago')
# #   8.times { Fabricate(:post_with_long_raw_content, user: user, topic: topic )}
# # end
# #
# # Timecop.freeze 20.days.ago do
# #   user = Fabricate.create(:user, name: 'user_with_12_topics_at_20_days_ago')
# #   12.times { Fabricate(:topic, user: user) }
# # end
# #
# # Timecop.freeze 3.days.ago do
# #   user = Fabricate.create(:user, name: 'user_with_3_topics_at_3_days_ago')
# #   3.times { Fabricate(:topic, user: user) }
# # end
# #
# # Timecop.freeze 12.days.ago do
# #   admin = Fabricate.create(:user, admin: true, name: 'Admin - admin_with_4_topics_at_12_days_ago')
# #   4.times { Fabricate(:topic, user: admin) }
# # end
# #
# # Timecop.freeze Date.yesterday do
# #   moderator = Fabricate.create(:user, moderator: true, name: 'Moderator - moderator_with_7_topics_at_yesterday')
# #   7.times { Fabricate(:topic, user: moderator) }
# # end
#
# ########################### END ACTIVE USER ########################################
#
# ########################### ACTIVE RESPONDER ########################################
# admin = Fabricate(:admin)
# support_category = Fabricate(:category, name: 'support', user: admin)
# bug_category = Fabricate(:category, name: 'bug', user: admin)
# feature_category = Fabricate(:category, name: 'feature', user: admin)
# another_category = Fabricate(:category, name: 'another', user: admin)
# different_category = Fabricate(:category, name: 'different', user: admin)
# group = Fabricate(:group)
# private_category = Fabricate(:private_category, user: admin, group: group)
# # end setup user
#
# Fabricate(:user, name: 'user_with_10_replies_to_support_and_bug_category_at_3_months_ago').tap do |user|
#   Timecop.freeze 3.months.ago do
#     support_topic = Fabricate(:topic, category_id: support_category.id)
#     bug_topic = Fabricate(:topic, category_id: support_category.id)
#     Fabricate.times(10, :post_with_long_raw_content, user: user, topic: support_topic)
#     Fabricate.times(10, :post_with_long_raw_content, user: user, topic: bug_topic)
#   end
# end
#
# Fabricate(:user, name: 'user_with_6_replies_to_support_and_bug_category_at_3_months_ago').tap do |user|
#   Timecop.freeze 3.months.ago do
#     support_topic = Fabricate(:topic, category_id: support_category.id)
#     bug_topic = Fabricate(:topic, category_id: support_category.id)
#     Fabricate.times(6, :post_with_long_raw_content, user: user, topic: support_topic)
#     Fabricate.times(6, :post_with_long_raw_content, user: user, topic: bug_topic)
#   end
# end
#
# Fabricate(:user, name: 'user_with_3_replies_to_support_and_bug_category_at_2_months_ago').tap do |user|
#   Timecop.freeze 2.months.ago do
#     support_topic = Fabricate(:topic, category_id: support_category.id)
#     bug_topic = Fabricate(:topic, category_id: support_category.id)
#     Fabricate.times(3, :post_with_long_raw_content, user: user, topic: support_topic)
#     Fabricate.times(3, :post_with_long_raw_content, user: user, topic: bug_topic)
#   end
# end
#
# Fabricate(:user, name: 'user_with_1_replies_to_support_and_bug_category_at_2_months_ago').tap do |user|
#   Timecop.freeze 2.months.ago do
#     support_topic = Fabricate(:topic, category_id: support_category.id)
#     bug_topic = Fabricate(:topic, category_id: support_category.id)
#     Fabricate(:post_with_long_raw_content, user: user, topic: support_topic)
#     Fabricate(:post_with_long_raw_content, user: user, topic: bug_topic)
#   end
# end
#
# feature_topic = Fabricate(:topic, category_id: feature_category.id)
# Fabricate(:user, name: 'user_with_10_replies_to_feature_category_at_3_months_ago').tap do |user|
#   Timecop.freeze 3.months.ago do
#     Fabricate.times(10, :post_with_long_raw_content, user: user, topic: feature_topic)
#   end
# end
#
# feature_topic = Fabricate(:topic, category_id: feature_category.id)
# Fabricate(:user, name: 'user_with_10_replies_to_feature_category_at_2_months_ago').tap do |user|
#   Timecop.freeze 2.months.ago do
#     Fabricate.times(10, :post_with_long_raw_content, user: user, topic: feature_topic)
#   end
# end
#
#
# feature_topic = Fabricate(:topic, category_id: feature_category.id)
# Fabricate(:user, name: 'user_with_12_replies_to_feature_category_at_1_month_ago').tap do |user|
#   Timecop.freeze 1.months.ago do
#     Fabricate.times(12, :post_with_long_raw_content, user: user, topic: feature_topic)
#   end
# end
#
# feature_topic = Fabricate(:topic, category_id: feature_category.id)
# Fabricate(:user, name: 'user_with_6_replies_to_feature_category_at_1_month_ago').tap do |user|
#   Timecop.freeze 1.months.ago do
#     Fabricate.times(12, :post_with_long_raw_content, user: user, topic: feature_topic)
#   end
# end
# ########################### END ACTIVE RESPONDER ########################################
