import Ember from 'ember';

export default Ember.Controller.extend({
  days: function() {
    var days = [...Array(31).keys()];
    days.shift();
    return days;
  }.property(),

  selectedDay: function() {
    return this.model.day;
  }.property(),

  hours: function() {
    return [...Array(24).keys()];
  }.property(),

  selectedHour: function() {
    return this.model.hour;
  }.property(),

  minutes: function() {
    return [...Array(60).keys()];
  }.property(),

  selectedMin: function() {
    return this.model.min;
  }.property(),

  actions: {
    previewEmail() {
      this.send('requestPreviewEmail')
    },
    setTimeout() {
      this.send('setEmailTimeout', {
        day: this.get('selectedDay'),
        hour: this.get('selectedHour'),
        min: this.get('selectedMin')
      })
    }
  }
});
