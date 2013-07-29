
require 'nokogiri'

module LexisNexisApi

  class PasswordChange
    extend XmlHelper

    #
    # options:
    #   :account
    #   :password
    #   :new_password
    #
    def initialize(account, password, new_password, subaccount=nil)
      @account, @password, @new_password, @subaccount = account, password, new_password, subaccount
      @xml = create_xml
      self
    end
    
    %q[
<ChoicePointAdminRequest
    xmlns="http://www.cpscreen.com/schemas"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.cpscreen.com/schemas AdminRequest.xsd"
    userId="XCHANGE"
    account="999999KLX"
    password="XXXXXXXXX">

  <ChangePassword>
    <Account>999999KLX</Account>
    <UserId>XCHANGE</UserId>
    <Password>As@34Gsg!#</Password>
    <NewPassword>the_new_password</NewPassword>
  </ChangePassword>

</ChoicePointAdminRequest>
    ]
    def create_xml
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.ChoicePointAdminRequest(
          :xmlns => 'http://www.cpscreen.com/schemas',
          :userId => 'XCHANGE',
          :account =>  "#{@account}#{@subaccount}",
          :password => @password
        ){
          xml.ChangePassword{
            xml.Account     "#{@account}#{@subaccount}"
            xml.UserId      'XCHANGE'
            xml.Password    @password
            xml.NewPassword @new_password
          }
        }
      end
      
      builder.to_xml
    end

    def to_xml
      self.class.soap_wrapper(@xml)
    end

  end

end
