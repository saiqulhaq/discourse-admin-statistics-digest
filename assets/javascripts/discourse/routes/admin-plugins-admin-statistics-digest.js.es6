import { ajax } from 'discourse/lib/ajax';

export default Discourse.Route.extend({
  controllerName: 'adminStatisticsDigestCategories',

  model() {
    return ajax('/admin/plugins/admin-statistics-digest/categories.json').then(model => model);
  },

  setupController: function(controller, model) {
    controller.set('model', model);
  },

  renderTemplate: function() {
    this.render('adminStatisticsDigestSetting');
  },

  actions: {
    toggleSelectedCategory(category) {
      ajax(`/admin/plugins/admin-statistics-digest/categories/${category.id}/toggle.json`, { type: 'put'})
        .then(model => model).then(() => this.refresh());
    }
  }
});

