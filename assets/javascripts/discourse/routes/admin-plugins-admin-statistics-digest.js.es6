import { ajax } from 'discourse/lib/ajax';

const baseUrl = '/admin/plugins/admin-statistics-digest';
export default Discourse.Route.extend({
  controllerName: 'adminStatisticsDigestSetting',

  model() {
    return Ember.RSVP.hash({
      categories: ajax(`${baseUrl}/categories.json`).then(model => model),
      emailSetting: ajax(`${baseUrl}/report-scheduler/timeout.json`).then(model => model)
    });
  },

  setupController: function(controller, model) {
    this.controllerFor('adminStatisticsDigestCategories').set('model', model.categories);
    this.controllerFor('adminStatisticsDigestEmailSetting').set('model', model.emailSetting);
  },

  renderTemplate: function() {
    this.render('adminStatisticsDigestSetting');
  },

  actions: {
    toggleSelectedCategory(category) {
      var model = this.controllerFor('adminStatisticsDigestCategories').get('model');
      model.removeObject(category);
      Ember.set(category, 'selected', !category.selected);
      model.pushObject(category);
      this.controllerFor('adminStatisticsDigestCategories').set('model', model);
    },
    saveSelectedCategory(model) {
      var data = model.filter(function(e) { return e.selected == true }).mapBy('id');
      ajax(`${baseUrl}/categories/update.json`, { type: 'put', data: {categories: data} }).then(() => this.refresh());
    },
    requestPreviewEmail() {
      ajax(`${baseUrl}/report-scheduler/preview.json`)
    },
    setEmailTimeout(timeOut) {
      ajax(`${baseUrl}/report-scheduler/timeout.json`, { type: 'put', data: timeOut }).then((res) => {
        if(!res.success) {
          alert('Failed to update the email send out time')
        }
      })
    }
  }
});

