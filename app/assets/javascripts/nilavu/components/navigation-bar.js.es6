import { default as computed, observes } from "ember-addons/ember-computed-decorators";
import NilavuURL from 'nilavu/lib/url';

export default Ember.Component.extend({
  tagName: 'ul',
  classNameBindings: [':page-sidebar-menu'],
  id: 'navigation-bar',

  @computed("filterMode", "navItems")
  selectedNavItem(filterMode, navItems){
    var item = navItems.find(i => i.get('filterMode').indexOf(filterMode) === 0);
    return item || navItems[0];
  },

  @observes("expanded")
  closedNav() {
    if (!this.get('expanded')) {
      this.ensureDropClosed();
    }
  },

  ensureDropClosed() {
    if (!this.get('expanded')) {
      this.set('expanded',false);
    }
    $(window).off('click.navigation-bar');
    NilavuURL.appEvents.off('dom:clean', this, this.ensureDropClosed);
  },

  actions: {
    toggleDrop() {
      this.set('expanded', !this.get('expanded'));

      if (this.get('expanded')) {
        NilavuURL.appEvents.on('dom:clean', this, this.ensureDropClosed);

        Em.run.next(() => {
          if (!this.get('expanded')) { return; }

          this.$('.drop a').on('click', () => {
            this.$('.drop').hide();
            this.set('expanded', false);
            return true;
          });

          $(window).on('click.navigation-bar', () => {
            this.set('expanded', false);
            return true;
          });
        });
      }
    }
  }
});
