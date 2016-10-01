import { ajax } from 'discourse/lib/ajax';
import { popupAjaxError } from 'discourse/lib/ajax-error';

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

  _showNotice() {
    var notice = bootbox.dialog('Submitted successfully');
    setTimeout(function() {
      notice.modal('hide')
    }, 1000)
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
      ajax(`${baseUrl}/categories/update.json`, { type: 'put', data: {categories: data} })
        .then(() => this.refresh()).catch(popupAjaxError);
    },
    requestPreviewEmail() {
      var self = this;
      ajax(`${baseUrl}/report-scheduler/preview.json`).then(() => {
        self._showNotice();
      }).catch(popupAjaxError)
    },
    setEmailTimeout(timeOut) {
      var self = this;
      ajax(`${baseUrl}/report-scheduler/timeout.json`, { type: 'put', data: timeOut }).then(() => {
        self._showNotice();
      }).catch(popupAjaxError)
    },
  }
});

