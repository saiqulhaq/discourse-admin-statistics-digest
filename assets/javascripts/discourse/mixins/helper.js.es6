import Ember from 'ember';

export default Ember.Mixin.create({
  _showNotice(msg) {
    if(typeof msg == 'undefined') {
      msg = 'Submitted successfully';
    }
    var notice = bootbox.dialog(msg);
    setTimeout(function() {
      notice.modal('hide')
    }, 1000)
  },
});
