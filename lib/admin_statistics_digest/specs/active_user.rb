module AdminStatisticsDigest
  module Specs
    class ActiveUser
      KEY = 'active_user'.freeze # config store key name
      LIKE_RECEIVED = 'like received'
      LIKE_GIVEN = 'live given'
      TOPICS = 'topics'
      REPLIES = 'replies'
      READ = 'read'
      VISITS = 'visits'

      SPECS_PARAMETERS = [LIKE_GIVEN, LIKE_RECEIVED, TOPICS, REPLIES, READ, VISITS].freeze

      attr_reader :config
      delegate :data, :add, :remove, :reset, to: :config

      def initialize
        @config = AdminStatisticsDigest::Config::Store.new(KEY, SPECS_PARAMETERS)
      end

      # @param [Hash] filters
      ### :signed_up_from Date or Time
      ### :signed_up_between Range of Date or Time
      # @return [String]
      def to_sql(filters = {})
        signed_up_from = filters.delete(:signed_up_from)
        signed_up_between = filters.delete(:signed_up_between)
        include_staff = !!filters.delete(:include_staff)

        return '' unless data.present?

        last_alias_name = 't1'
        current_alias_name = nil
        heading_name = 'user_id'
        groups = [heading_name]
        orders = [] # don't sort by user id
        sql = "SELECT #{last_alias_name}.\"id\" AS \"#{heading_name}\" from \"#{User.table_name}\" AS #{last_alias_name} WHERE #{last_alias_name}.\"id\" > 0"

        sql += " AND #{last_alias_name}.\"created_at\" >= '#{signed_up_from}' " if !!signed_up_from
        sql += " AND #{last_alias_name}.\"created_at\" >= '#{signed_up_between.first}' AND #{last_alias_name}.\"created_at\" < '#{signed_up_between.last}'" if !!signed_up_between
        sql += " AND (#{last_alias_name}.\"admin\" = false AND #{last_alias_name}.\"moderator\" = false)" unless !!include_staff


        data.each do |spec|
          case spec
            when TOPICS
              last_alias_name = 't2'
              current_alias_name = 'c1'
              heading_name = 'topics'
              sql = "SELECT #{last_alias_name}.*, count(#{current_alias_name}) as \"#{heading_name}\" FROM \"#{Topic.table_name}\" as #{current_alias_name} RIGHT JOIN ( #{sql} ) AS #{last_alias_name} ON #{current_alias_name}.\"user_id\" = #{last_alias_name}.\"user_id\" "
              sql += group_by(last_alias_name, groups)
              groups << heading_name
              orders << heading_name

            when REPLIES
              last_alias_name = 't3'
              current_alias_name = 'c2'
              heading_name = 'posts'
              sql = "SELECT #{last_alias_name}.*, count(#{current_alias_name}) as \"#{heading_name}\" FROM \"#{Post.table_name}\" as #{current_alias_name} RIGHT JOIN ( #{sql} ) AS #{last_alias_name} ON #{last_alias_name}.\"user_id\" = #{current_alias_name}.\"user_id\" "
              sql += " AND (#{current_alias_name}.\"topic_id\" IN (SELECT \"id\" from \"#{Topic.table_name}\" WHERE(\"topics\".\"archetype\" = 'regular'))) AND (#{current_alias_name}.\"deleted_at\" IS NULL)"
              sql += group_by(last_alias_name, groups)
              groups << heading_name
              orders << heading_name

            when LIKE_RECEIVED
              last_alias_name = 't4'
              current_alias_name = 'c3'
              heading_name = 'like_received'
              sql = "SELECT #{last_alias_name}.*, count(#{current_alias_name}) as \"#{heading_name}\" FROM \"#{UserAction.table_name}\" as #{current_alias_name} RIGHT JOIN ( #{sql} ) AS #{last_alias_name} ON #{current_alias_name}.\"user_id\" = #{last_alias_name}.\"user_id\" "
              sql += " AND (#{current_alias_name}.\"action_type\" = #{UserAction::WAS_LIKED})"
              sql += group_by(last_alias_name, groups)
              groups << heading_name
              orders << heading_name
            when LIKE_GIVEN
              last_alias_name = 't5'
              current_alias_name = 'c4'
              heading_name = 'like_given'
              sql = "SELECT #{last_alias_name}.*, count(#{current_alias_name}) as \"#{heading_name}\" FROM \"#{UserAction.table_name}\" as #{current_alias_name} RIGHT JOIN ( #{sql} ) AS #{last_alias_name} ON #{current_alias_name}.\"user_id\" = #{last_alias_name}.\"user_id\" "
              sql += " AND (#{current_alias_name}.\"action_type\" = #{UserAction::LIKE})"
              sql += group_by(last_alias_name, groups)
              groups << heading_name
              orders << heading_name
            when READ
              last_alias_name = 't6'
              current_alias_name = 'c5'
              heading_name = 'read'
              sql = "SELECT #{last_alias_name}.*, COALESCE(SUM(#{current_alias_name}.\"posts_read\"),0) as \"#{heading_name}\" FROM \"#{UserVisit.table_name}\" as #{current_alias_name} RIGHT JOIN ( #{sql} ) AS #{last_alias_name} ON #{current_alias_name}.\"user_id\" = #{last_alias_name}.\"user_id\" "
              sql += " AND (#{current_alias_name}.\"visited_at\" >= #{signed_up_from})" if !!signed_up_from
              sql += " AND #{current_alias_name}.\"visited_at\" >= '#{signed_up_between.first}' AND #{last_alias_name}.\"visited_at\" <= '#{signed_up_between.last}'" if !!signed_up_between

              sql += group_by(last_alias_name, groups)
              groups << heading_name
              orders << heading_name
            when VISITS
              last_alias_name = 't7'
              current_alias_name = 'c6'
              heading_name = 'days_visited'
              sql = "SELECT #{last_alias_name}.*, COUNT(#{current_alias_name}.\"id\") as \"#{heading_name}\" FROM \"#{UserVisit.table_name}\" as #{current_alias_name} RIGHT JOIN ( #{sql} ) AS #{last_alias_name} ON #{current_alias_name}.\"user_id\" = #{last_alias_name}.\"user_id\" "
              sql += " AND (#{current_alias_name}.\"visited_at\" >= #{signed_up_from})" if !!signed_up_from
              sql += " AND #{current_alias_name}.\"visited_at\" >= '#{signed_up_between.first}' AND #{last_alias_name}.\"visited_at\" <= '#{signed_up_between.last}'" if !!signed_up_between

              sql += group_by(last_alias_name, groups)
              groups << heading_name
              orders << heading_name
            else
              nil
          end
        end
        sql += order_by(orders) if orders.present?

        sql
      end

      private
      def group_by(table_name, groups)
        return ' ' unless groups.present?
        sql = ' GROUP BY '
        groups.each do |group|
          sql += " #{table_name}.\"#{group}\" "
          sql += ', ' if group != groups.last
        end
        sql
      end

      def order_by(orders)
        sql = ' ORDER BY '
        orders.each do |order|
          sql += "#{order} DESC"
          sql += ', ' if order != orders.last
        end
        sql
      end

    end
  end
end

