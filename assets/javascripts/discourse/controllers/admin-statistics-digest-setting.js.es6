import Ember from 'ember';

export default Ember.ArrayController.extend({
  needs: ['adminStatisticsDigestCategories', 'adminStatisticsDigestEmailSetting'],
});