module AdminStatisticsDigest
  module Specs
    class ActiveUser
      KEY = 'active_user'.freeze # config store key name
      LIKE_RECEIVED = 'like received'.freeze
      LIKE_GIVEN = 'live given'.freeze
      TOPICS = 'topics'.freeze
      REPLIES = 'replies'.freeze
      READ = 'read'.freeze
      VISITS = 'visits'.freeze

      SPECS_PARAMETERS = [LIKE_GIVEN, LIKE_RECEIVED, TOPICS, REPLIES, READ, VISITS].freeze

      delegate :data, :add, :remove, :reset, to: :config

      def initialize
        self.config = AdminStatisticsDigest::Specs::Config.new(KEY, SPECS_PARAMETERS)
      end

      # @param [Hash] filters
      #  :signed_up_from [Date]
      #  :signed_up_between [Range of Date]
      #  :active_range [Range of Date]
      # @return [String]
      def to_sql(filters = {})
        active_range = filters[:active_range]
        signed_up_from = filters[:signed_up_from]
        signed_up_between = filters[:signed_up_between]
        include_staff = !!filters[:include_staff] # default value is false
        limit = filters[:limit]

        # we are joining many tables recursively, so there are left and right tables for each query

        heading_name = 'user_id'
        sql = "SELECT #{left_table_alias}.\"id\" AS \"#{heading_name}\" from \"#{User.table_name}\" AS #{left_table_alias} WHERE #{left_table_alias}.\"id\" > 0"

        if !!signed_up_from
          sql += " AND (#{left_table_alias}.\"created_at\" >= '#{signed_up_from}')"
        end

        sql += if !!signed_up_between
                 " AND (#{left_table_alias}.\"created_at\" BETWEEN '#{signed_up_between.first}' AND '#{signed_up_between.last}')"
               elsif !!active_range
                 "AND (#{left_table_alias}.\"created_at\" <= '#{active_range.first}')"
               else
                 ''
               end

        unless !!include_staff
          sql += " AND (#{left_table_alias}.\"admin\" = false AND #{left_table_alias}.\"moderator\" = false)"
        end

        groups = [heading_name]
        orders = [] # don't sort by user id

        data.each do |spec|
          generate_new_left_table_alias_name
          generate_new_right_table_alias_name

          case spec
            when TOPICS
              heading_name = 'topics'
              sql = "SELECT #{left_table_alias}.*, count(#{right_table_alias}) as \"#{heading_name}\" FROM \"#{Topic.table_name}\" as #{right_table_alias} RIGHT JOIN ( #{sql} ) AS #{left_table_alias} ON #{right_table_alias}.\"user_id\" = #{left_table_alias}.\"user_id\" "
              sql += " AND (#{right_table_alias}.\"created_at\" BETWEEN '#{active_range.first}' AND '#{active_range.last}')" unless active_range.nil?

              sql += group_by(left_table_alias, groups)
              groups << heading_name
              orders << heading_name

            when REPLIES
              heading_name = 'replies'
              sql = "SELECT #{left_table_alias}.*, count(#{right_table_alias}) as \"#{heading_name}\" FROM \"#{Post.table_name}\" as #{right_table_alias} RIGHT JOIN ( #{sql} ) AS #{left_table_alias} ON #{left_table_alias}.\"user_id\" = #{right_table_alias}.\"user_id\" "
              sql += " AND (#{right_table_alias}.\"topic_id\" IN (SELECT \"id\" from \"#{Topic.table_name}\" WHERE(\"topics\".\"archetype\" = 'regular'))) AND (#{right_table_alias}.\"deleted_at\" IS NULL)"
              sql += " AND (#{right_table_alias}.\"created_at\" BETWEEN '#{active_range.first}' AND '#{active_range.last}')" unless active_range.nil?

              sql += group_by(left_table_alias, groups)
              groups << heading_name
              orders << heading_name

            when LIKE_RECEIVED
              heading_name = 'like_received'
              sql = "SELECT #{left_table_alias}.*, count(#{right_table_alias}) as \"#{heading_name}\" FROM \"#{UserAction.table_name}\" as #{right_table_alias} RIGHT JOIN ( #{sql} ) AS #{left_table_alias} ON #{right_table_alias}.\"user_id\" = #{left_table_alias}.\"user_id\" "
              sql += " AND (#{right_table_alias}.\"action_type\" = #{UserAction::WAS_LIKED})"
              sql += " AND (#{right_table_alias}.\"created_at\" BETWEEN '#{active_range.first}' AND '#{active_range.last}')" unless active_range.nil?
              sql += group_by(left_table_alias, groups)
              groups << heading_name
              orders << heading_name
            when LIKE_GIVEN
              heading_name = 'like_given'
              sql = "SELECT #{left_table_alias}.*, count(#{right_table_alias}) as \"#{heading_name}\" FROM \"#{UserAction.table_name}\" as #{right_table_alias} RIGHT JOIN ( #{sql} ) AS #{left_table_alias} ON #{right_table_alias}.\"user_id\" = #{left_table_alias}.\"user_id\" "
              sql += " AND (#{right_table_alias}.\"action_type\" = #{UserAction::LIKE})"
              sql += " AND (#{right_table_alias}.\"created_at\" BETWEEN '#{active_range.first}' AND '#{active_range.last}')" unless active_range.nil?
              sql += group_by(left_table_alias, groups)
              groups << heading_name
              orders << heading_name
            when READ
              heading_name = 'read'
              sql = "SELECT #{left_table_alias}.*, COALESCE(SUM(#{right_table_alias}.\"posts_read\"),0) as \"#{heading_name}\" FROM \"#{UserVisit.table_name}\" as #{right_table_alias} RIGHT JOIN ( #{sql} ) AS #{left_table_alias} ON #{right_table_alias}.\"user_id\" = #{left_table_alias}.\"user_id\" "
              sql += " AND (#{right_table_alias}.\"visited_at\" >= #{signed_up_from})" if !!signed_up_from
              sql += " AND (#{right_table_alias}.\"visited_at\" >= '#{signed_up_between.first}' AND #{left_table_alias}.\"visited_at\" <= \"#{signed_up_between.last}\")" if !!signed_up_between
              sql += " AND (#{right_table_alias}.\"visited_at\" BETWEEN '#{active_range.first}' AND '#{active_range.last}')" unless active_range.nil?
              sql += group_by(left_table_alias, groups)
              groups << heading_name
              orders << heading_name
            when VISITS
              heading_name = 'days_visited'
              sql = "SELECT #{left_table_alias}.*, COUNT(#{right_table_alias}.\"id\") as \"#{heading_name}\" FROM \"#{UserVisit.table_name}\" as #{right_table_alias} RIGHT JOIN ( #{sql} ) AS #{left_table_alias} ON #{right_table_alias}.\"user_id\" = #{left_table_alias}.\"user_id\" "
              sql += " AND (#{right_table_alias}.\"visited_at\" >= #{signed_up_from})" if !!signed_up_from
              sql += " AND (#{right_table_alias}.\"visited_at\" >= '#{signed_up_between.first}' AND #{left_table_alias}.\"visited_at\" <= \"#{signed_up_between.last}\")" if !!signed_up_between
              sql += " AND (#{right_table_alias}.\"visited_at\" BETWEEN '#{active_range.first}' AND '#{active_range.last}')" unless active_range.nil?
              sql += group_by(left_table_alias, groups)
              groups << heading_name
              orders << heading_name
            else
              raise "Undefined action #{spec.to_s}"
          end
        end

        sql += order_by(orders) if orders.present?
        sql += " LIMIT #{limit}" if limit.present?

        "SELECT users.name, users.username, res.* from users AS users RIGHT JOIN (#{sql}) as res ON users.id = res.user_id"
      end

      private
      attr_accessor :config

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

      def left_table_alias
        @left_table ||= 't1'
      end

      def generate_new_left_table_alias_name
        ta = left_table_alias.match(/(\w)(\d*)/).to_a
        @left_table = "#{ta[1]}#{ta[2].to_i + 1}"
      end

      def right_table_alias
        @right_table ||= 'c1'
      end

      def generate_new_right_table_alias_name
        ta = right_table_alias.match(/(\w)(\d*)/).to_a
        @right_table = "#{ta[1]}#{ta[2].to_i + 1}"
      end
    end
  end
end

