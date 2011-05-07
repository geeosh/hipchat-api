require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'fakeweb'

describe "HipChat::API" do
  before(:each) do
    FakeWeb.allow_net_connect = false
    FakeWeb.clean_registry
    @hipchat_api = HipChat::API.new('token')
  end
    
  it "should be the correct version" do
    HipChat::API::VERSION.should == '1.0.0'
  end
  
  it "should create a new instance with the correct parameters" do  
    @hipchat_api.token.should == 'token'
    @hipchat_api.hipchat_api_url.should == HipChat::API::HIPCHAT_API_URL
  end
  
  it "should allow http headers to be set" do
    @hipchat_api.expects(:headers).at_least_once
    
    @hipchat_api.set_http_headers({'Accept' => 'application/json'})
  end
  
  it "should allow a timeout to be set" do
    @hipchat_api.expects(:default_timeout).at_least_once
    
    @hipchat_api.set_timeout(10)
  end
  
  it "should return a list of rooms" do
    FakeWeb.register_uri(:get, 
                         %r|#{HipChat::API::HIPCHAT_API_URL}/rooms/list|, 
                         :body => File.join(File.dirname(__FILE__), 'fakeweb', 'rooms_list_response.json'), 
                         :content_type => "application/json")
  
    rooms_list_response = @hipchat_api.rooms_list
    rooms_list_response.should_not be nil
    rooms_list_response['rooms'].size.should be 2
  end
  
  it "should return the correct room informaton for a room_id" do
    FakeWeb.register_uri(:get, 
                         %r|#{HipChat::API::HIPCHAT_API_URL}/rooms/show|, 
                         :body => File.join(File.dirname(__FILE__), 'fakeweb', 'rooms_show_response.json'), 
                         :content_type => "application/json")
  
    rooms_show_response = @hipchat_api.rooms_show(7)
    rooms_show_response.should_not be nil
    rooms_show_response['room']['topic'].should == 'Chef is so awesome.'
  end

  it "should send a message" do
    FakeWeb.register_uri(:post, 
                         %r|#{HipChat::API::HIPCHAT_API_URL}/rooms/message|, 
                         :body => File.join(File.dirname(__FILE__), 'fakeweb', 'rooms_message_response.json'), 
                         :content_type => "application/json")
  
    rooms_message_response = @hipchat_api.rooms_message(10, 'Alerts', 'A new user signed up')
    rooms_message_response.should_not be nil
    rooms_message_response['status'].should == 'sent'
  end

  it "should return a history of messages" do
    FakeWeb.register_uri(:get, 
                         %r|#{HipChat::API::HIPCHAT_API_URL}/rooms/history|, 
                         :body => File.join(File.dirname(__FILE__), 'fakeweb', 'rooms_history_response.json'), 
                         :content_type => "application/json")
  
    rooms_history_response = @hipchat_api.rooms_history(10, '2010-11-19', 'PST')
    rooms_history_response.should_not be nil
    rooms_history_response['messages'].size.should be 3
  end

  it "should create a user" do
    FakeWeb.register_uri(:post, 
                         %r|#{HipChat::API::HIPCHAT_API_URL}/users/create|, 
                         :body => File.join(File.dirname(__FILE__), 'fakeweb', 'users_create_response.json'), 
                         :content_type => "application/json")
  
    users_create_response = @hipchat_api.users_create('New Guy', 'new@company.com', 'intern')
    users_create_response.should_not be nil
    users_create_response['user']['name'].should == 'New Guy'
  end

  it "should delete a user" do
    FakeWeb.register_uri(:post, 
                         %r|#{HipChat::API::HIPCHAT_API_URL}/users/delete|, 
                         :body => File.join(File.dirname(__FILE__), 'fakeweb', 'users_delete_response.json'), 
                         :content_type => "application/json")
  
    users_delete_response = @hipchat_api.users_delete(5)
    users_delete_response.should_not be nil
    users_delete_response['deleted'].should be true
  end

  it "should return a list of users" do
    FakeWeb.register_uri(:get, 
                         %r|#{HipChat::API::HIPCHAT_API_URL}/users/list|, 
                         :body => File.join(File.dirname(__FILE__), 'fakeweb', 'users_list_response.json'), 
                         :content_type => "application/json")
  
    users_list_response = @hipchat_api.users_list
    users_list_response.should_not be nil
    users_list_response['users'].size.should be 3
  end

  it "should show the details for a user" do
    FakeWeb.register_uri(:get, 
                         %r|#{HipChat::API::HIPCHAT_API_URL}/users/show|, 
                         :body => File.join(File.dirname(__FILE__), 'fakeweb', 'users_show_response.json'), 
                         :content_type => "application/json")
  
    users_show_response = @hipchat_api.users_show(5)
    users_show_response.should_not be nil
    users_show_response['user']['name'].should == 'Garret Heaton'
  end
  
  after(:each) do
    FakeWeb.allow_net_connect = true
  end
end
