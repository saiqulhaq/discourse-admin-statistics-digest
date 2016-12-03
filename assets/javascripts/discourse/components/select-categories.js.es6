import Ember from 'ember';

import { ajax } from 'discourse/lib/ajax';
import Config from 'discourse/plugins/discourse-admin-statistics-digest/discourse/mixins/config';
import Helper from 'discourse/plugins/discourse-admin-statistics-digest/discourse/mixins/helper';
import { popupAjaxError } from 'discourse/lib/ajax-error';

export default Ember.Component.extend(Config, Helper, {

  actions: {
    toggle(catId) {
      var category = this.categories.find(x => x.id == catId);
      Ember.set(category, 'selected', !category.selected);
    },

    updateCategories() {
      var data = this.categories.filter(e => e.selected == true).mapBy('id');
      ajax(`${this.baseUrl}/categories/update.json`, { type: 'put', data: {categories: data} })
        .then(() => this._showNotice())
        .catch(popupAjaxError);
    },

  }
});
