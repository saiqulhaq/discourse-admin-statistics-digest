import { ajax } from 'discourse/lib/ajax';

const baseUrl = '/admin/plugins/admin-statistics-digest';
export default Discourse.Route.extend({
  controllerName: 'adminStatisticsDigestSetting',

  model() {
    return ajax('/admin/plugins/admin-statistics-digest/categories.json').then(model => model);
  },

  setupController: function(controller, model) {
    this.controllerFor('adminStatisticsDigestCategories').set('model', model)
  },

  renderTemplate: function() {
    this.render('adminStatisticsDigestSetting');
  },

  actions: {
    toggleSelectedCategory(category) {
      ajax(`${baseUrl}/categories/${category.id}/toggle.json`, { type: 'put'})
        .then(() => this.refresh());
    },
    requestPreviewEmail() {
      ajax(`${baseUrl}/report-scheduler/preview.json`)
    }
  }
});

