export default function() {
  //Fake route
  this.route('dummy');
  // Error page
  this.route('exception', { path: '/exception' });

  this.resource('about', { path: '/about' });


  // Topic routes
  this.resource('topic', { path: '/t/:slug/:id' }, function() {
    this.route('fromParams', { path: '/' });
    this.route('fromParamsNear', { path: '/:nearPost' });
  });
  this.resource('topicBySlug', { path: '/t/:slug' });
  this.route('topicUnsubscribe', { path: '/t/:slug/:id/unsubscribe' });


  this.resource('discovery', { path: '/' }, function() {
  // top
  this.route('top');
  //filters
  Nilavu.Site.currentProp('filters').forEach(filter => {
    this.route(filter, { path: '/' + filter });
    this.route(filter + 'ParentCategory', { path: '/c/:slug/l/' + filter });
    this.route(filter + 'CategoryNone', { path: '/c/:slug/none/l/' + filter });
    this.route(filter + 'Category', { path: '/c/:parentSlug/:slug/l/' + filter });
   });

    this.route('categories');

    // default filter for a category
    this.route('parentCategory', { path: '/c/:slug' });
    this.route('categoryNone', { path: '/c/:slug/none' });
    this.route('category', { path: '/c/:parentSlug/:slug' });
    this.route('categoryWithID', { path: '/c/:parentSlug/:slug/:id' });

    // homepage
    this.route(Nilavu.Utilities.defaultHomepage(), { path: '/' });

  });


  // User routes
  this.resource('users');
  this.resource('user', { path: '/users/:username' }, function() {
    this.route('summary');
    this.resource('userActivity', { path: '/activity' }, function() {
      this.route('topics');
      this.route('replies');
      this.route('likesGiven', {path: 'likes-given'});
      this.route('bookmarks');
      this.route('pending');
    });

    this.resource('userNotifications', {path: '/notifications'}, function(){
      this.route('responses');
      this.route('likesReceived', { path: 'likes-received'});
      this.route('mentions');
      this.route('edits');
    });

  this.resource('userPrivateMessages', { path: '/messages' }, function() {
      this.route('sent');
      this.route('archive');
      this.route('group', { path: 'group/:name'});
      this.route('groupArchive', { path: 'group/:name/archive'});
    });

    this.resource('preferences', function() {
      this.route('username');
      this.route('email');
      this.route('about', { path: '/about-me' });
      this.route('badgeTitle', { path: '/badge_title' });
      this.route('card-badge', { path: '/card-badge' });
    });

  });
  this.route('signup', {path: '/signup'});

  this.route('login', {path: '/login'});

  this.route('login-preferences');
  this.route('forgot-password', {path: '/password-reset'});

  this.route('new-topic', {path: '/new-topic'});
  this.route('new-message', {path: '/new-message'});

}
