export default Discourse.Route.extend({
  controllerName: 'admin-statistics-digest',

  model() {
    const p1 = Discourse.ajax('/admin/plugins/admin-statistics-digest/categories.json', {cache: true});
    return p1.then(model => model);
  },

  setupController: function(controller, model) {
    controller.setProperties(model);
  },

  renderTemplate: function() {
    this.render('adminStatisticsDigest');
  },
});

