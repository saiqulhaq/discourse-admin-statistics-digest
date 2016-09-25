import Ember from 'ember';

export default Ember.Controller.extend({
  actions: {
    select(category) {
      this.send('toggleSelectedCategory', category)
    }
  }
});
