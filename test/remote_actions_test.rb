require 'test_helper'

class RemoteActionsTest < ActiveSupport::TestCase

  test 'should get host_from_url' do
    req = LexisNexisApi::RemoteActions::Request.new(:url => 'http://test.lexisnexis.fake/foo/bar')
    assert_equal 'test.lexisnexis.fake', req.host_from_url

    req = LexisNexisApi::RemoteActions::Request.new(:url => 'http://this.that-test.lexisnexis.fake/foo/bar')
    assert_equal 'this.that-test.lexisnexis.fake', req.host_from_url

    req = LexisNexisApi::RemoteActions::Request.new(:url => 'http://test2.lexisnexis.fake')
    assert_equal 'test2.lexisnexis.fake', req.host_from_url

    req = LexisNexisApi::RemoteActions::Request.new(:url => 'test3.lexisnexis.fake/foo/bar')
    assert_equal 'test3.lexisnexis.fake', req.host_from_url

    req = LexisNexisApi::RemoteActions::Request.new(:url => '')
    assert_equal nil, req.host_from_url
  end

  test 'should get port_from_url' do
    req = LexisNexisApi::RemoteActions::Request.new(:url => 'http://test.lexisnexis.fake/foo/bar')
    assert_equal 80, req.port_from_url

    req = LexisNexisApi::RemoteActions::Request.new(:url => 'https://test.lexisnexis.fake/foo/bar')
    assert_equal 443, req.port_from_url

    req = LexisNexisApi::RemoteActions::Request.new(:url => 'http://test.lexisnexis.fake:8765/foo/bar')
    assert_equal 8765, req.port_from_url
  end

  test 'should get is_ssl?' do
    req = LexisNexisApi::RemoteActions::Request.new(:url => 'http://test.lexisnexis.fake/foo/bar')
    assert !req.is_ssl?

    req = LexisNexisApi::RemoteActions::Request.new(:url => 'https://test.lexisnexis.fake/foo/bar')
    assert req.is_ssl?
  end

  test 'should get response errors' do
    res = LexisNexisApi::RemoteActions::MockResponse.new(:body => LexisNexisApi::XmlSamples::CHANGE_PASSWORD_FAIL_RESPONSE)
    assert_equal '250', res.errors[:error_code]
    assert_equal 'Invalid old password', res.errors[:error_description]
  end

end
