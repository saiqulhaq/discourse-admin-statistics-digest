require_dependency 'plugin_store'

class AdminStatisticsDigest::ActiveResponderCategory
  PS_KEY_NAME = 'active_responder'.freeze

  class << self
    Item = Struct.new(:id, :name, :selected)

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

    def update_categories(categories)
      categories.map! { |c| c.to_i }
      selected_categories = []
      all.map do |cat|
        if categories.include?(cat.id)
          selected_categories.push(cat.id)
        end
      end

      PluginStore.set(AdminStatisticsDigest.plugin_name, PS_KEY_NAME, selected_categories)
    end
  end

end
