$: << File.expand_path(File.dirname(__FILE__) + '/../lib')
require 'lexis_nexis_api/xml_helper'
require 'lexis_nexis_api/background_check'
require 'lexis_nexis_api/password_change'
require 'lexis_nexis_api/remote_actions'

module LexisNexisApi

  URLS = {
    :test => {
      :wsdl_background_checks => {
        :name => 'WSDL - Back Ground Checks',
        :description => 'URL for background screening web services WSDL',
        :url => 'http://screen.lexisnexis.com/schemas/CPBackgroundCheck.wsdl'
      },
      :order_one_step => {
        :name => 'New Requests URL - Customer Test (One-Step)',
        :description => 'URL for web service CreateOrder',
        :url => 'https://screentest.lexisnexis.com/pub/xchange/order'
      },
      :order_two_step => {
        :name => 'New Requests URL - Customer Test (Two-Step)',
        :description => 'URL for web service CreateOrder',
        :url => 'https://screentest.lexisnexis.com/pub/xchange/startOrder'
      },
      :provider_website => {
        :name => 'Provider Website URL - Test',
        :description => 'CPScreen.com URL',
        :url => 'http://screentest.lexisnexis.com/'
      },
      :response_post => {
        :name => 'Response URL - Customer Test',
        :description => 'URL ChoicePoint uses to post results to ATS',
        :url => ''
      },
      :wsdl_admin => {
        :name => 'WSDL - Admin',
        :description => 'URL for admin web services WSDL',
        :url => 'http://screen.lexisnexis.com/schemas/admin.wsdl'
      },
      :password_change => {
        :name => 'Password Change Requests URL - Test',
        :description => 'URL for web service ChangePasswords, GetPackages',
        :url => 'https://screentest.lexisnexis.com/pub/xchange/ws/admin'
      },
    },

    :prod => {
      :wsdl_background_checks => {
        :name => 'WSDL - Back Ground Checks',
        :description => 'URL for background screening web services WSDL',
        :url => 'http://screen.lexisnexis.com/schemas/CPBackgroundCheck.wsdl'
      },
      :order_one_step => {
        :name => 'New Requests URL - Production (One-Step)',
        :description => 'URL for web service CreateOrder',
        :url => 'https://screen.lexisnexis.com/pub/xchange/order'
      },
      :order_two_step => {
        :name => 'New Requests URL - Production (Two-Step)',
        :description => 'URL for web service CreateOrder',
        :url => 'https://screen.lexisnexis.com/pub/xchange/startOrder'
      },
      :provider_website => {
        :name => 'Provider Website URL - Production',
        :description => 'CPScreen.com URL',
        :url => 'http://screen.lexisnexis.com'
      },
      :response_post => {
        :name => 'Response URL - Production',
        :description => 'URL ChoicePoint uses to post results to ATS',
        :url => ''
      },
      :wsdl_admin => {
        :name => 'WSDL - Admin',
        :description => 'URL for admin web services WSDL',
        :url => 'http://screen.lexisnexis.com/schemas/admin.wsdl'
      },
      :password_change => {
        :name => 'Password Change Requests URL - Production',
        :description => 'URL for web service ChangePasswords, GetPackages',
        :url => 'https://screen.lexisnexis.com/pub/xchange/ws/admin'
      },
    }
  }


  class Api

    # mode: prod[uction] or test
    def initialize(mode)
      @mode = mode
      # test system password is 'Password2' until changed
      self
    end

    def mode
      @mode.to_s =~ /prod/i ? :prod : :test
    end

    def order(background_check)
      req = LexisNexisApi::RemoteActions::Request.new(
        :url => url(:order_one_step),
        :body => background_check.to_xml
      )
      req.send_request
    end

    def password_change_request(password_change)
      req = LexisNexisApi::RemoteActions::Request.new(
        :url => url(:password_change),
        :body => password_change.to_xml
      )
      req.send_request
    end

    def url(type)
      LexisNexisApi::URLS[mode][type][:url]
    end

  end # class Api


end
