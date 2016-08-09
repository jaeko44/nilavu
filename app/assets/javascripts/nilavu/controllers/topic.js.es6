import BufferedContent from 'nilavu/mixins/buffered-content';
import {
    spinnerHTML
} from 'nilavu/helpers/loading-spinner';
import Topic from 'nilavu/models/topic';
import {
    popupAjaxError
} from 'nilavu/lib/ajax-error';
import computed from 'ember-addons/ember-computed-decorators';
import NilavuURL from 'nilavu/lib/url';
import showModal from 'nilavu/lib/show-modal';

export default Ember.Controller.extend(BufferedContent, {
    needs: ['application', 'modal'],
    progress: 10,
    selectedTab: null,
    panels: null,
    spinnerStartIn: false,
    spinnerStopIn: false,
    spinnerRebootIn: false,
    spinnerDeleteIn: false,
    spinnerRefreshIn: false,
    stopVisible: true,
    rerenderTriggers: ['isUploading'],


    _initPanels: function() {
        this.set('panels', []);
        this.set('selectedTab', 'info');
    }.on('init'),

    infoSelected: function() {
        return this.selectedTab == 'info';
    }.property('selectedTab'),

    storageSelected: function() {
        return this.selectedTab == 'storage';
    }.property('selectedTab'),

    networkSelected: function() {
        return this.selectedTab == 'network';
    }.property('selectedTab'),

    cpuSelected: function() {
        return this.selectedTab == 'cpu';
    }.property('selectedTab'),

    ramSelected: function() {
        return this.selectedTab == 'ram';
    }.property('selectedTab'),

    keysSelected: function() {
        return this.selectedTab == 'keys';
    }.property('selectedTab'),

    logsSelected: function() {
        return this.selectedTab == 'logs';
    }.property('selectedTab'),

    content_state: function() {
        return I18n.t("vm_management.info.content_state");
    }.property(),
    
    title: Ember.computed.alias('fullName'),
    
    fullName: function() {
        //var js = this._filterInputs("domain");
        //return this.get('model.name') + "." + js;
        return this.get('model.name')
    }.property('model.name'),
    
    machineStatus: function() {
        return this.get('model.status')
    }.property('model.status.message'),
    
    hasInputs: Em.computed.notEmpty('model.inputs'),
    hasOutputs: Em.computed.notEmpty('model.outputs'),

    _filterInputs(key) {
        if (!this.get('hasInputs')) return "";
        if (!this.get('model.inputs').filterBy('key', key)[0]) return "";
        return this.get('model.inputs').filterBy('key', key)[0].value;
    },

    _filterOutputs(key) {
        if (!this.get('hasOutputs')) return "";
        if (!this.get('model.outputs').filterBy('key', key)[0]) return "";
        return this.get('model.outputs').filterBy('key', key)[0].value;
    },

    showStartSpinner: function() {
        return this.get('spinnerStartIn');
    }.property('spinnerStartIn'),

    showStop: function() {
        return this.get('stopVisible');
    }.property('stopVisible'),

    showStopSpinner: function() {
        return this.get('spinnerStopIn');
    }.property('spinnerStopIn'),

    showRebootSpinner: function() {
        return this.get('spinnerRebootIn');
    }.property('spinnerRebootIn'),

    showDeleteSpinner: function() {
        return this.get('spinnerDeleteIn');
    }.property('spinnerDeleteIn'),

    showRefreshSpinner: function() {
        return this.get('spinnerRefreshIn');
    }.property('spinnerRefreshIn'),

    getData(reqAction) {
        return {
            id: this.get('model').id,
            cat_id: this.get('model').asms_id,
            name: this.get('model').name,
            req_action: reqAction,
            cattype: this.get('model').tosca_type.split(".")[1],
            category: "control"
        };
    },

    getDeleteData() {
        return {
            id: this.get('model').id,
            cat_id: this.get('model').asms_id,
            name: this.get('model').name,
            action: "delete",
            cattype: this.get('model').tosca_type.split(".")[1],
            category: "state"
        };
    },

    delete() {
        var self = this;
        this.set('spinnerDeleteIn', true);
        Nilavu.ajax('/t/' + this.get('model').id + "/delete", {
            data: this.getDeleteData(),
            type: 'DELETE'
        }).then(function(result) {
            self.set('spinnerDeleteIn', false);
            if (result.success) {
                self.notificationMessages.success(I18n.t("vm_management.delete_success"));
            } else {
                self.notificationMessages.error(I18n.t("vm_management.error"));
            }
        }).catch(function(e) {
            self.set('spinnerDeleteIn', false);
            self.notificationMessages.error(I18n.t("vm_management.error"));
        });
    },

    actions: {

        refresh() {
            const self = this;
            self.set('spinnerRefreshIn', true);
            const promise = this.get('model').reload().then(function(result) {
                self.set('spinnerRefreshIn', false);
            }).catch(function(e) {
                self.notificationMessages.error(I18n.t("vm_management.topic_load_error"));
                self.set('spinnerRefreshIn', false);
            });
        },

        showVNC() {
            const host = this._filterOutputs("vnchost"),
                port = this._filterOutputs("vncport");
            if (host == undefined || host == "" || port == "" || port == undefined) {
                this.notificationMessages.error(I18n.t('vm_management.vnc_host_port_empty'));
            } else {
                showModal('vnc').setProperties({
                    host: host,
                    port: port
                });
            }

        },

        start() {
            var self = this;
            this.set('spinnerStartIn', true);
            Nilavu.ajax('/t/' + this.get('model').id + "/start", {
                data: this.getData("control"),
                type: 'POST'
            }).then(function(result) {
                self.set('spinnerStartIn', false);
                if (result.success) {
                    self.set('stopVisible', true);
                    self.notificationMessages.success(I18n.t("vm_management.start_success"));
                } else {
                    self.set('stopVisible', false);
                    self.notificationMessages.error(I18n.t("vm_management.error"));
                }
            }).catch(function(e) {
                self.set('spinnerStartIn', false);
                self.notificationMessages.error(I18n.t("vm_management.error"));
            });
        },


        stop() {
            var self = this;
            this.set('stopVisible', true);
            this.set('spinnerStopIn', true);
            Nilavu.ajax('/t/' + this.get('model').id + "/stop", {
                data: this.getData("control"),
                type: 'POST'
            }).then(function(result) {
                self.set('spinnerStopIn', false);
                if (result.success) {
                    self.set('stopVisible', false);
                    self.notificationMessages.success(I18n.t("vm_management.stop_success"));
                } else {
                    self.set('stopVisible', true);
                    self.notificationMessages.error(I18n.t("vm_management.error"));
                }
            }).catch(function(e) {
                self.set('spinnerStopIn', false);
                self.set('showStop', false);
                console.log(e);
                self.notificationMessages.error(I18n.t("vm_management.error"));
            });
        },

        restart() {
            var self = this;
            this.set('spinnerRebootIn', true);
            Nilavu.ajax('/t/' + this.get('model').id + "/restart", {
                data: this.getData("control"),
                type: 'POST'
            }).then(function(result) {
                self.set('spinnerRebootIn', false);
                if (result.success) {
                    self.notificationMessages.success(I18n.t("vm_management.restart_success"));
                } else {
                    self.notificationMessages.error(I18n.t("vm_management.error"));
                }
            }).catch(function(e) {
                self.set('spinnerRebootIn', false);
                self.notificationMessages.error(I18n.t("vm_management.error"));
            });
        },

        destroy() {
            bootbox.confirm(I18n.t("vm_management.confirm_delete"), result => {
                if (result) {
                    this.delete();
                }
            })
        },

    },

    hasError: Ember.computed.or('model.notFoundHtml', 'model.message'),

    noErrorYet: Ember.computed.not('hasError'),

    loadingHTML: function() {
        return spinnerHTML;
    }.property()

});
