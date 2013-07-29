require File.join(File.dirname(__FILE__), 'test_helper')

class PasswordChangeTest < ActiveSupport::TestCase

  test 'should get new without subaccount' do
    pc = LexisNexisApi::PasswordChange.new(
      '12345',
      'secret',
      'secreter'
    )

    xml = pc.to_xml

    assert_node xml, 'ChoicePointAdminRequest', :attributes => {:account => '12345'}
    assert_node xml, 'Account', :content => '12345'
  end

  test 'should get new with subaccount' do
    pc = LexisNexisApi::PasswordChange.new(
      '12345',
      'secret',
      'secreter',
      'ABC'
    )

    xml = pc.to_xml

    assert_node xml, 'ChoicePointAdminRequest', :attributes => {:account => '12345ABC'}
    assert_node xml, 'Account', :content => '12345ABC'
  end

end
