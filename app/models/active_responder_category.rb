require_dependency 'plugin_store'
require_relative '../../lib/admin_statistics_digest'

class AdminStatisticsDigest::ActiveResponderCategory
  PS_KEY_NAME = 'active_responder'.freeze

  class << self
    Item = Struct.new(:id, :name, :selected)

    def toggle_selection(category_id)
      category = find(category_id)
      selected_cats = Set.new(PluginStore.get(AdminStatisticsDigest.plugin_name, PS_KEY_NAME))
      if category.selected
        selected_cats.delete(category.id)
        PluginStore.set(AdminStatisticsDigest.plugin_name, PS_KEY_NAME, selected_cats.to_a)
      else
        selected_cats.add(category.id)
        PluginStore.set(AdminStatisticsDigest.plugin_name, PS_KEY_NAME, selected_cats.to_a)
      end
    end

    def all
      selected_cats = PluginStore.get(AdminStatisticsDigest.plugin_name, PS_KEY_NAME).to_a
      Category.pluck(:id, :name).map  do |c|
        Item.new(c.first, c.last, selected_cats.include?(c.first))
      end
    end

    def find(category_id)
      is_selected = all.find {|c| c.id == category_id }
      if (category = Category.select(:id, :name).find_by(id: category_id))
        Item.new(category.id, category.name, is_selected.nil? ? false : is_selected.selected)
      else
        false
      end
    end

  end
end
