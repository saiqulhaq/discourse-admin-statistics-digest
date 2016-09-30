import Ember from 'ember';

export default Ember.ArrayController.extend({
  itemController: 'adminStatisticsDigestCategory',
  sortProperties: ['name'],
  actions: {
    updateCategories() {
      this.send('saveSelectedCategory', this.get('model'))
    }
  }
});
