import showModal from 'nilavu/lib/show-modal';
import Group from 'nilavu/models/group';

export default Nilavu.Route.extend({
  model() {
    return this.modelFor('adminUser');
  },

  afterModel(model) {
    if (this.currentUser.get('admin')) {
      const self = this;
      return Group.findAll().then(function(groups){
        self._availableGroups = groups.filterBy('automatic', false);
        return model;
      });
    }
  },

  setupController(controller, model) {
    controller.setProperties({
      originalPrimaryGroupId: model.get('primary_group_id'),
      availableGroups: this._availableGroups,
      model
    });
  },

  actions: {
    showSuspendModal(model) {
      showModal('modals/admin-suspend-user', { model });
      this.controllerFor('modal').set('modalClass', 'suspend-user-modal');
    }
  }
});
