import { ajax } from 'discourse/lib/ajax';
import Config from 'discourse/plugins/discourse-admin-statistics-digest/discourse/mixins/config';
import Helper from 'discourse/plugins/discourse-admin-statistics-digest/discourse/mixins/helper';

export default Discourse.Route.extend(Config, Helper, {
  controllerName: 'adminStatisticsDigestSetting',

  model() {
    return Ember.RSVP.hash({
      categories: ajax(`${this.baseUrl}/categories.json`).then(model => model),
      emailSetting: ajax(`${this.baseUrl}/report-scheduler/timeout.json`).then(model => model)
    });
  },

  renderTemplate: function() {
    this.render('adminStatisticsDigestSetting');
  },
});

