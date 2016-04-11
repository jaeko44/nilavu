class Auth::GoogleOAuth2Authenticator < Auth::Authenticator


  def name
    "google_oauth2"
  end

  def after_authenticate(auth_hash)
    session_info = parse_hash(auth_hash)
    google_hash = session_info[:google]

    result = Auth::Result.new
    result.email = session_info[:email]
    result.email_valid = session_info[:email_valid]
    result.first_name = google_hash[:first_name]

    result.extra_data = google_hash
    result
  end

  def after_create_account(user, auth)
    data = auth[:extra_data]
  end

  #  config.google_authorization_uri = 'https://accounts.google.com/o/oauth2/auth'
  #  config.google_token_credential_uri = 'https://accounts.google.com/o/oauth2/token'
  #  config.google_scope = 'https://www.googleapis.com/auth/userinfo.email'
  #  config.google_redirect_uri = 'https://www.megam.co/auth/google_oauth2/callback'
  def register_middleware(omniauth)
    # jwt encoding is causing auth to fail in quite a few conditions
    # skipping
    omniauth.provider :google_oauth2,
           :setup => lambda { |env|
              strategy = env["omniauth.strategy"]
              strategy.options[:client_id] = SiteSetting.google_oauth2_client_id
              strategy.options[:client_secret] = SiteSetting.google_oauth2_client_secret
             },
           :scope => "user:email",
           skip_jwt:  true
  end

  protected

  def parse_hash(hash)
    extra = hash[:extra][:raw_info]

    h = {}

    h[:email] = hash[:info][:email]
    h[:name] = hash[:info][:name]
    h[:email_valid] = hash[:extra][:raw_info][:email_verified]

    h[:google] = {
      google_user_id: hash[:uid] || extra[:sub],
      email: extra[:email],
      first_name: extra[:given_name],
      last_name: extra[:family_name],
      gender: extra[:gender],
      name: extra[:name],
      link: extra[:hd],
      profile_link: extra[:profile],
      picture: extra[:picture]
    }

    h
  end
end
