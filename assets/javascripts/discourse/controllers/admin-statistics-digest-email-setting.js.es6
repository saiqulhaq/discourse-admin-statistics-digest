import Ember from 'ember';

export default Ember.Controller.extend({
  actions: {
    previewEmail() {
      this.send('requestPreviewEmail')
    }
  }
});
