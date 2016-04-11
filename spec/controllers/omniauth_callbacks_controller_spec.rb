require 'rails_helper'

describe OmniauthCallbacksController do

  context ".find_authenticator" do
    it "fails if a provider is disabled" do
      #SiteSetting.stubs("enable_twitter_logins?").returns(false)
      expect(lambda {
        OmniauthCallbacksController.find_authenticator("twitter")
      }).to raise_error
    end

    it "fails for unknown" do
      expect(lambda {
        OmniauthCallbacksController.find_authenticator("twitter1")
      }).to raise_error
    end

    it "finds an authenticator when enabled" do
      #SiteSetting.stubs("enable_twitter_logins?").returns(true)
      expect(OmniauthCallbacksController.find_authenticator("twitter")).not_to eq(nil)
    end
  end

end
