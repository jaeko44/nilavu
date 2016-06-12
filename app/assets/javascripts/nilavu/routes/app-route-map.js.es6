export default function() {

    //Fake route
    this.route('dummy');
    // Error page
    this.route('exception', { path: '/exception' });

    this.resource('about', { path: '/about' });

    this.resource('discovery', { path: '/' }, function() {
        // homepage
        this.route(Nilavu.Utilities.defaultHomepage(), { path: '/' });

        // filters
        Nilavu.Site.currentProp('filters').forEach(filter => {
            this.route(filter, { path: '/' + filter });
        });

    });

    // Topic routes
    this.resource('topic', { path: '/t/:id' }, function() {
        this.route('show', { path: '/' });
        this.route('predeploy', { path: '/predeploy' });
        
        //path is  /t/:id/start
        this.resource('topicActions', function() {
            this.route('start');
            this.route('stop');
            this.route('destroy');
            this.route('reboot');
        });

    });

    this.route('billing', { path: '/billing' });

    this.route('marketplaces', { path: '/marketplaces' });

    this.route('storages', { path: '/storages' });

    // User routes
    this.resource('users');
    this.resource('user', { path: '/users/:username' }, function() {
        this.route('summary');
        this.resource('userActivity', { path: '/activity' }, function() {
            this.route('topics');
            this.route('replies');
            this.route('likesGiven', { path: 'likes-given' });
            this.route('bookmarks');
            this.route('pending');
        });

        this.resource('userNotifications', { path: '/notifications' }, function() {
            this.route('responses');
            this.route('likesReceived', { path: 'likes-received' });
            this.route('mentions');
            this.route('edits');
        });

        this.resource('userPrivateMessages', { path: '/messages' }, function() {
            this.route('sent');
            this.route('archive');
            this.route('group', { path: 'group/:name' });
            this.route('groupArchive', { path: 'group/:name/archive' });
        });

        this.resource('preferences', function() {
            this.route('username');
            this.route('email');
        });

    });
    this.route('signup', { path: '/signup' });

    this.route('login', { path: '/login' });

    this.route('login-preferences');
    this.route('forgot-password', { path: '/password-reset' });

}
