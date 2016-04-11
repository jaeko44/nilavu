require 'rails_helper'
require 'nilavu'

describe Nilavu do

  before do
  end

  context 'current_hostname' do

    it 'returns the hostname from the current db connection' do
      expect(Nilavu.current_hostname).to eq('foo.com')
    end

  end

  context 'base_url' do
    context 'when https is off' do
      before do
        SiteSetting.expects(:use_https?).returns(false)
      end

      it 'has a non https base url' do
        expect(Nilavu.base_url).to eq("http://foo.com")
      end
    end

    context 'when https is on' do
      before do
        SiteSetting.expects(:use_https?).returns(true)
      end

      it 'has a non-ssl base url' do
        expect(Nilavu.base_url).to eq("https://foo.com")
      end
    end

    context 'with a non standard port specified' do
      before do
        SiteSetting.stubs(:port).returns(3000)
      end

      it "returns the non standart port in the base url" do
        expect(Nilavu.base_url).to eq("http://foo.com:3000")
      end
    end
  end

  context '#site_contact_user' do

    let!(:admin) { Fabricate(:admin) }
    let!(:another_admin) { Fabricate(:admin) }

    it 'returns the user specified by the site setting site_contact_username' do
      SiteSetting.stubs(:site_contact_username).returns(another_admin.username)
      expect(Nilavu.site_contact_user).to eq(another_admin)
    end

    it 'returns the user specified by the site setting site_contact_username regardless of its case' do
      SiteSetting.stubs(:site_contact_username).returns(another_admin.username.upcase)
      expect(Nilavu.site_contact_user).to eq(another_admin)
    end

    it 'returns the system user otherwise' do
      SiteSetting.stubs(:site_contact_username).returns(nil)
      expect(Nilavu.site_contact_user.username).to eq("system")
    end

  end

  context "#readonly_mode?" do
    it "is false by default" do
      expect(Nilavu.readonly_mode?).to eq(false)
    end

    it "returns true when the key is present in redis" do
      $redis.expects(:get).with(Nilavu.readonly_mode_key).returns("1")
      expect(Nilavu.readonly_mode?).to eq(true)
    end

    it "returns true when Nilavu is recently read only" do
      Nilavu.received_readonly!
      expect(Nilavu.readonly_mode?).to eq(true)
    end
  end

  context "#handle_exception" do

    it "should not fail when called" do
      exception = StandardError.new

      Nilavu.handle_job_exception(exception, nil, nil)
      expect(logger.exception).to eq(exception)
      expect(logger.context.keys).to eq([:current_db, :current_hostname])
    end

    it "correctly passes extra context" do
      exception = StandardError.new

      Nilavu.handle_job_exception(exception, {message: "Doing a test", post_id: 31}, nil)
      expect(logger.exception).to eq(exception)
      expect(logger.context.keys.sort).to eq([:current_db, :current_hostname, :message, :post_id].sort)
    end
  end

end
