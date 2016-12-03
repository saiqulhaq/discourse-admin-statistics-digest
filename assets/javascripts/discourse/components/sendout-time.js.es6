import Ember from 'ember';
import { ajax } from 'discourse/lib/ajax';
import { popupAjaxError } from 'discourse/lib/ajax-error';
import Config from 'discourse/plugins/discourse-admin-statistics-digest/discourse/mixins/config';
import Helper from 'discourse/plugins/discourse-admin-statistics-digest/discourse/mixins/helper';

export default Ember.Component.extend(Config, Helper, {
  days: function() {
    var days = [...Array(31).keys()];
    days.shift();
    return days;
  }.property(),

  hours: function() {
    return [...Array(24).keys()];
  }.property(),

  minutes: function() {
    return [...Array(60).keys()];
  }.property(),

  selectedDay: null,
  selectedHour: null,
  selectedMin: null,

  actions: {
    updateTimeOut(type) {
      var propName, value;

      propName = 'selected' + type.capitalize();
      value = $('.sendout-time').find('#select-' + type).val();

      if(propName && value) {
        this.set(propName, parseInt(value));
      }
    },

    submit() {
      var timeOut = {
        day: this.get('selectedDay'),
        hour: this.get('selectedHour'),
        min: this.get('selectedMin')
      };

      ajax(`${this.baseUrl}/report-scheduler/timeout.json`, { type: 'put', data: timeOut })
        .then(() => this._showNotice())
        .catch(popupAjaxError)
    }
  }
});
