require File.join(File.dirname(__FILE__), 'test_helper')

module Garb
  class RequestTest < Test::Unit::TestCase
    
    context "The Request class" do
      should "build an http object from the url" do
        uri = URI.parse("http://example.com")
        http_mock = mock do |m|
          m.expects(:use_ssl=).with(true)
          m.expects(:verify_mode=).with(OpenSSL::SSL::VERIFY_NONE)
        end

        request = Request.new("http://example.com")        
        Net::HTTP.expects(:new).with(uri.host, uri.port).returns(http_mock)
        assert_equal http_mock, request.http
      end

      should "be able to make an HTTP POST request to the Google API" do
        uri = URI.parse(Session::URL)
        params = {:email => 'blah@example.com'}
        response = stub

        request_mock = mock do |m|
          m.expects(:set_form_data).with(params)
        end
        
        http_mock = mock do |m|
          m.expects(:request).with(request_mock).returns(response)
        end
        
        request = Request.new(Session::URL, params)
        request.stubs(:http).returns(http_mock)        
        Net::HTTP::Post.expects(:new).with(uri.path).returns(request_mock)
        assert_equal response, request.post
      end
    
      should "be able to make a get request of the google api" do
        session = Session.new('ga@example.com', 'password')
        uri = URI.parse(Session::URL)
        session.auth_token = 'abcdefg12345'
        
        params = {}
        
        request_mock = mock do |m|
          m.expects(:[]=).with('Authorization', "GoogleLogin auth=#{session.auth_token}")
        end
        
        http_mock = mock do |m|
          m.expects(:request).with(request_mock).returns(nil)
        end
        
        request = Request.new(Session::URL, params)
        request.session = session
        request.stubs(:http).returns(http_mock)
        
        Net::HTTP::Get.expects(:new).with(uri.path).returns(request_mock)
        
        request.get
      end
      
      should "return a new Atom::Feed object with the google api data from get request" do
        session = Session.new('ga@example.com', 'password')
        uri = URI.parse(Session::URL)
        session.auth_token = 'abcdefg12345'
        
        params = {}
        response = stub(:body => 'some xml')
        
        request_stub = stub do |s|
          s.stubs(:[]=).with('Authorization', "GoogleLogin auth=#{session.auth_token}")
        end
        
        http_stub = stub do |s|
          s.stubs(:request).with(request_stub).returns(response)
        end
        
        request = Request.new(Session::URL, params)
        request.session = session
        request.stubs(:http).returns(http_stub)
        
        Net::HTTP::Get.stubs(:new).with(uri.path).returns(request_stub)
        
        Atom::Feed.expects(:load_feed).with('some xml').returns('has a feed')
        
        assert_equal 'has a feed', request.get
      end
      
      should "have url parameters" do
        request = Request.new("http://example.com", {'ids' => 'ga:1234'})
        assert_equal "?ids=ga:1234", request.url_parameters
      end
      
      should "have no url parameters if there are no parameters" do
        request = Request.new("http://example.com")
        assert_equal "", request.url_parameters
      end      
    end
  end
end