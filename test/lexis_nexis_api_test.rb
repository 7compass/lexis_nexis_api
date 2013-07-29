require File.join(File.dirname(__FILE__), 'test_helper')

class LexisNexisApiTest < ActiveSupport::TestCase

  def setup
    # DO YOU REALLY WANT TO SEND THESE TEST REQUESTS TO LEXIS-NEXIS?
    @SEND_REQUESTS = false
  end

  test 'should order packages' do
    if @SEND_REQUESTS
      %w(Eligible Ineligible).each do |status|
        @status = status
        @client_reference1 = "Make me #{@status}"
        @order_as_user_id = nil
        @order_as_account_suffix = nil

        [2112, 2113, 2114, 2116, 2117, 2168, 2169, 2360].each do |id|
          bg_hash = background_check_hash(:account => '036483', :password => 'Password2',
            :order_as_user_id => @order_as_user_id,
            :order_as_account_suffix => @order_as_account_suffix,
            :client_reference1 => @client_reference1
          )
          bg_hash[:person_names] << name_hash(:last_name => @status)
          bg_hash[:postal_addresses] << address_hash
          bg_hash[:licenses] << license_hash
          bg_hash.merge!(ssnv_hash)

          bg = LexisNexisApi::BackgroundCheck.for_package(id, bg_hash)
          api = LexisNexisApi::Api.new(:test)
          response = api.order(bg)

          puts "response for package #{id}: #{response.inspect}"
          assert_no_match %r{<ErrorReport>}, response.body, "Error on package #{id}"
        end
      end
    end
  end

  test 'should order packages with suffix' do
    if @SEND_REQUESTS
      %w(Eligible Ineligible).each do |status|
        @status = status
        @client_reference1 = "Make me #{@status}"
        @order_as_user_id = 'test_user'
        @order_as_account_suffix = 'TST'

        [2112, 2113, 2114, 2116, 2117, 2168, 2169, 2360].each do |id|
          bg_hash = background_check_hash(:account => '036483', :password => 'Password2',
            :order_as_user_id => @order_as_user_id,
            :order_as_account_suffix => @order_as_account_suffix,
            :client_reference1 => @client_reference1
          )
          bg_hash[:person_names] << name_hash(:last_name => @status)
          bg_hash[:postal_addresses] << address_hash
          bg_hash[:licenses] << license_hash
          bg_hash.merge!(ssnv_hash)

          bg = LexisNexisApi::BackgroundCheck.for_package(id, bg_hash)
          api = LexisNexisApi::Api.new(:test)
          response = api.order(bg)

          puts "response for package #{id}: #{response.inspect}"
          assert_no_match %r{<ErrorReport>}, response.body, "Error on package #{id}"
        end
      end
    end
  end

end
