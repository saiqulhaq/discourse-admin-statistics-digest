module AdminStatisticsDigest
  module Specs
    class ActiveUser
      KEY = 'active_user'.freeze # plugin store key name
      SPECS_PARAMETERS = ['like received', 'like given', 'topics', 'replies', 'viewed', 'read', 'visits'].freeze

      def initialize
        @store = AdminStatisticsDigest::Specs::Store.new(KEY, SPECS_PARAMETERS)
      end

      def specs
        @store
      end

      def to_sql(filters = {})
        signed_up_from = filters.delete(:signed_up_from)
        signed_up_between = filters.delete(:signed_up_between)
        include_staff = !!filters.delete(:include_staff)

        raise ArgumentError if signed_up_from.present? && signed_up_between.present?
        raise ArgumentError if signed_up_from.present? && !(signed_up_from.kind_of?(Date) || signed_up_from.kind_of?(Time))
        raise ArgumentError if signed_up_between.present? && !signed_up_between.is_a?(Range)

        return '' unless specs.data.present?

        last_alias_name = 't1'
        groups = []
        orders = []
        sql = "SELECT #{last_alias_name}.\"id\" AS \"user_id\" from \"users\" AS #{last_alias_name} "

        sql += " WHERE #{last_alias_name}.\"created_at\" >= '#{signed_up_from}' " if !!signed_up_from
        sql += " WHERE #{last_alias_name}.\"created_at\" >= '#{signed_up_between.first}' AND #{last_alias_name}.\"created_at\" < '#{signed_up_between.last}'" if !!signed_up_between

        connector = sql.include?('WHERE') ? ' AND ' : ' WHERE '
        sql += " #{connector} #{last_alias_name}.\"admin\" = false OR #{last_alias_name}.\"moderator\" = false" unless !!include_staff

        groups << 'user_id'
        specs.data.each do |spec|
          case spec
            when 'replies'
              last_alias_name = 't4'
              sql = "SELECT #{last_alias_name}.*, count(t5) as \"posts\" FROM \"posts\" as t5 RIGHT JOIN ( #{sql} ) AS t4 ON #{last_alias_name}.\"user_id\" = t5.\"user_id\" "
              sql += " AND (t5.\"topic_id\" IN (SELECT \"id\" from \"topics\" WHERE(\"topics\".\"archetype\" = 'regular'))) AND (t5.\"deleted_at\" IS NULL)"
              sql += group_by(last_alias_name, groups)
              groups << 'posts'
              orders << 'posts'
            when 'topics'
              last_alias_name = 't3'
              sql = "SELECT #{last_alias_name}.*, count(t2) as \"topics\" FROM \"topics\" as t2 RIGHT JOIN ( #{sql} ) AS #{last_alias_name} ON t2.\"user_id\" = #{last_alias_name}.\"user_id\" "
              sql += group_by(last_alias_name, groups)
              groups << 'topics'
              orders << 'topics'
            when 'topics'
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

