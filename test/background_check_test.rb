require File.join(File.dirname(__FILE__), 'test_helper')

class BackgroundCheckTest < ActiveSupport::TestCase

  test 'should get mvr node' do
    bg_hash = background_check_hash(:account => '036483', :password => 'Password2')
    one_year_ago = 1.year.ago.to_date
    bg_hash[:licenses] << license_hash(
      {
        :valid_from => one_year_ago,
        :valid_to => nil,
        :country_code => 'US',
        :license_number => '1234ABC',
        :license_region => 'FL',
      }
    )
    bg_hash[:licenses] << license_hash(
      {
        :valid_from => '1999-03-13',
        :valid_to => one_year_ago,
        :country_code => 'US',
        :license_number => 'in&val<id>',
        :license_region => 'CA',
      }
    )
    
    bg = LexisNexisApi::BackgroundCheck.for_package(2116, bg_hash)
    xml = bg.to_xml

    assert_node xml, 'License', :attributes => {:validFrom => one_year_ago.to_s(:db), :validTo => ""}
    assert_node xml, 'LicenseNumber', :content => '1234ABC'
    assert_node xml, 'LicenseRegion', :content => 'FL'

    assert_node xml, 'License', :attributes => {:validFrom => "1999-03-13", :validTo => one_year_ago.to_s(:db)}
    assert_node xml, 'LicenseNumber', :content => 'in&amp;val&lt;id&gt;'
    assert_node xml, 'LicenseRegion', :content => 'CA'
  end

  test 'should get names' do
    bg_hash = background_check_hash(:account => '036483', :password => 'Password2')
    bg_hash[:person_names] << name_hash({
        :type => 'subject',
        :first_name => 'First1',
        :middle_name => 'M1',
        :last_name => 'Last1'
      })
    bg_hash[:person_names] << name_hash({
        :type => 'alias',
        :first_name => 'First2',
        :middle_name => 'M2',
        :last_name => 'Last2'
      })
    bg = LexisNexisApi::BackgroundCheck.for_package(2112, bg_hash)
    xml = bg.to_xml

    assert_node xml, 'PersonName', :attributes => {:type => 'subject'}, :child => {:node_name => 'GivenName', :content => 'First1'}
    assert_node xml, 'PersonName', :attributes => {:type => 'subject'}, :child => {:node_name => 'MiddleName', :content => 'M1'}
    assert_node xml, 'PersonName', :attributes => {:type => 'subject'}, :child => {:node_name => 'FamilyName', :content => 'Last1'}

    assert_node xml, 'PersonName', :attributes => {:type => 'alias'}, :child => {:node_name => 'GivenName', :content => 'First2'}
    assert_node xml, 'PersonName', :attributes => {:type => 'alias'}, :child => {:node_name => 'MiddleName', :content => 'M2'}
    assert_node xml, 'PersonName', :attributes => {:type => 'alias'}, :child => {:node_name => 'FamilyName', :content => 'Last2'}
  end

  test 'should get addresses' do
    bg_hash = background_check_hash(:account => '036483', :password => 'Password2')
    bg_hash[:postal_addresses] << address_hash({
        :type => 'current',
        :valid_from => '2010-01-02',
        :valid_to => '2020-12-31',
        :municipality => 'Madison',
        :region => 'WI',
        :postal_code => '53711',
        :country_code => 'US',
        :address1 => '1234 Main St',
        :address2 => '',
      })
    bg_hash[:postal_addresses] << address_hash({
        :type => 'prior',
        :valid_from => '2001-02-03',
        :valid_to => '2009-11-12',
        :municipality => 'Podunk',
        :region => 'KS',
        :postal_code => '98765',
        :country_code => 'US',
        :address1 => '222 There St',
        :address2 => 'Apt 2',
      })
    bg = LexisNexisApi::BackgroundCheck.for_package(2112, bg_hash)
    xml = bg.to_xml

    assert_node xml, 'PostalAddress', :attributes => {:type => 'current', :validFrom => '2010-01-02', :validTo => '2020-12-31'},
        :child => {:node_name => 'Municipality', :content => 'Madison'}
    assert_node xml, 'PostalAddress', :attributes => {:type => 'current', :validFrom => '2010-01-02', :validTo => '2020-12-31'},
        :child => {:node_name => 'Region', :content => 'WI'}
    assert_node xml, 'PostalAddress', :attributes => {:type => 'current', :validFrom => '2010-01-02', :validTo => '2020-12-31'},
        :child => {:node_name => 'PostalCode', :content => '53711'}
    assert_node xml, 'PostalAddress', :attributes => {:type => 'current', :validFrom => '2010-01-02', :validTo => '2020-12-31'},
        :child => {:node_name => 'CountryCode', :content => 'US'}
    assert_node xml, 'PostalAddress', :attributes => {:type => 'current', :validFrom => '2010-01-02', :validTo => '2020-12-31'},
        :child => {:node_name => 'DeliveryAddress', :child => {
        :node_name => 'AddressLine', :content => '1234 Main St'
      }}
    assert_no_node xml, 'PostalAddress', :attributes => {:type => 'current', :validFrom => '2010-01-02', :validTo => '2020-12-31'},
        :child => {:node_name => 'DeliveryAddress', :child => {
        :node_name => 'AddressLine', :content => ''
      }}

    assert_node xml, 'PostalAddress', :attributes => {:type => 'prior', :validFrom => '2001-02-03', :validTo => '2009-11-12'},
        :child => {:node_name => 'Municipality', :content => 'Podunk'}
    assert_node xml, 'PostalAddress', :attributes => {:type => 'prior', :validFrom => '2001-02-03', :validTo => '2009-11-12'},
        :child => {:node_name => 'Region', :content => 'KS'}
    assert_node xml, 'PostalAddress', :attributes => {:type => 'prior', :validFrom => '2001-02-03', :validTo => '2009-11-12'},
        :child => {:node_name => 'PostalCode', :content => '98765'}
    assert_node xml, 'PostalAddress', :attributes => {:type => 'prior', :validFrom => '2001-02-03', :validTo => '2009-11-12'},
        :child => {:node_name => 'CountryCode', :content => 'US'}
    assert_node xml, 'PostalAddress', :attributes => {:type => 'prior', :validFrom => '2001-02-03', :validTo => '2009-11-12'},
        :child => {:node_name => 'DeliveryAddress', :child => {
        :node_name => 'AddressLine', :content => '222 There St'
      }}
    assert_node xml, 'PostalAddress', :attributes => {:type => 'prior', :validFrom => '2001-02-03', :validTo => '2009-11-12'},
        :child => {:node_name => 'DeliveryAddress', :child => {
        :node_name => 'AddressLine', :content => 'Apt 2'
      }}
  end

  test 'should get ssnv' do
    bg_hash = background_check_hash(:account => '036483', :password => 'Password2')
    bg_hash.merge!(ssnv_hash({
          :ssn => '333224444',
          :date_of_birth => '1951-02-03'
        }))
    bg = LexisNexisApi::BackgroundCheck.for_package(2112, bg_hash)
    xml = bg.to_xml
    assert_node xml, 'DemographicDetail', :child => {
      :node_name => 'GovernmentId', :content => '333224444'
    }
    assert_node xml, 'DemographicDetail', :child => {
      :node_name => 'DateOfBirth', :content => '1951-02-03'
    }
  end

  test 'should have soap wrapper in to_xml' do
    bg_hash = background_check_hash(:account => '036483', :password => 'Password2')
    bg = LexisNexisApi::BackgroundCheck.for_package(2112, bg_hash)
    xml = bg.to_xml
    assert_node xml, 'soapenv:Envelope'
  end

  test 'should have order_as user and account' do
    bg_hash = background_check_hash(:account => '036483', :password => 'Password2', :order_as_user_id => 'joeuser', :order_as_account_suffix => 'XYZ')
    bg = LexisNexisApi::BackgroundCheck.for_package(2112, bg_hash)
    xml = bg.to_xml
    
    assert_node xml, 'ClientReferences', :child => {:node_name => 'ClientReference', :content => 'joeuser'}
    assert_node xml, 'OrderAccount', :child => {:node_name => 'Account', :content => '036483XYZ'}
  end

  test '2112 should have correct parts' do
    bg_hash = background_check_hash(:account => '036483', :password => 'Password2')
    bg_hash[:person_names] << name_hash
    bg_hash[:postal_addresses] << address_hash
    bg_hash[:licenses] << license_hash
    bg_hash.merge!(ssnv_hash)

    bg = LexisNexisApi::BackgroundCheck.for_package(2112, bg_hash)
    xml = bg.to_xml

    assert_node xml, 'PackageId', :content => '2112'
    assert_node xml, 'PersonalData', :child => {:node_name => 'PersonName'}
    assert_node xml, 'PersonalData', :child => {:node_name => 'PostalAddress'}
    assert_node xml, 'PersonalData', :child => {:node_name => 'DemographicDetail', :child => {:node_name => 'GovernmentId'}}
    assert_node xml, 'PersonalData', :child => {:node_name => 'DemographicDetail', :child => {:node_name => 'DateOfBirth'}}
    assert_no_node xml, 'PersonalData', :child => {:node_name => 'Licenses'}
  end

  test '2113 should have correct parts' do
    bg_hash = background_check_hash(:account => '036483', :password => 'Password2')
    bg_hash[:person_names] << name_hash
    bg_hash[:postal_addresses] << address_hash
    bg_hash[:licenses] << license_hash
    bg_hash.merge!(ssnv_hash)

    bg = LexisNexisApi::BackgroundCheck.for_package(2113, bg_hash)
    xml = bg.to_xml

    assert_node xml, 'PackageId', :content => '2113'
    assert_node xml, 'PersonalData', :child => {:node_name => 'PersonName'}
    assert_node xml, 'PersonalData', :child => {:node_name => 'PostalAddress'}
    assert_node xml, 'PersonalData', :child => {:node_name => 'DemographicDetail', :child => {:node_name => 'GovernmentId'}}
    assert_node xml, 'PersonalData', :child => {:node_name => 'DemographicDetail', :child => {:node_name => 'DateOfBirth'}}
    assert_no_node xml, 'PersonalData', :child => {:node_name => 'Licenses'}
  end

  test '2114 should have correct parts' do
    bg_hash = background_check_hash(:account => '036483', :password => 'Password2')
    bg_hash[:person_names] << name_hash
    bg_hash[:postal_addresses] << address_hash
    bg_hash[:licenses] << license_hash
    bg_hash.merge!(ssnv_hash)

    bg = LexisNexisApi::BackgroundCheck.for_package(2114, bg_hash)
    xml = bg.to_xml

    assert_node xml, 'PackageId', :content => '2114'
    assert_node xml, 'PersonalData', :child => {:node_name => 'PersonName'}
    assert_node xml, 'PersonalData', :child => {:node_name => 'PostalAddress'}
    assert_node xml, 'PersonalData', :child => {:node_name => 'DemographicDetail', :child => {:node_name => 'GovernmentId'}}
    assert_node xml, 'PersonalData', :child => {:node_name => 'DemographicDetail', :child => {:node_name => 'DateOfBirth'}}
    assert_node xml, 'PersonalData', :child => {:node_name => 'Licenses'}
  end

  test '2116 should have correct parts' do
    bg_hash = background_check_hash(:account => '036483', :password => 'Password2')
    bg_hash[:person_names] << name_hash
    bg_hash[:postal_addresses] << address_hash
    bg_hash[:licenses] << license_hash
    bg_hash.merge!(ssnv_hash)

    bg = LexisNexisApi::BackgroundCheck.for_package(2116, bg_hash)
    xml = bg.to_xml

    assert_node xml, 'PackageId', :content => '2116'
    assert_node xml, 'PersonalData', :child => {:node_name => 'PersonName'}
    assert_node xml, 'PersonalData', :child => {:node_name => 'PostalAddress'}
    assert_node xml, 'PersonalData', :child => {:node_name => 'DemographicDetail', :child => {:node_name => 'GovernmentId'}}
    assert_node xml, 'PersonalData', :child => {:node_name => 'DemographicDetail', :child => {:node_name => 'DateOfBirth'}}
    assert_node xml, 'PersonalData', :child => {:node_name => 'Licenses'}
  end

  test '2117 should have correct parts' do
    bg_hash = background_check_hash(:account => '036483', :password => 'Password2')
    bg_hash[:person_names] << name_hash
    bg_hash[:postal_addresses] << address_hash
    bg_hash[:licenses] << license_hash
    bg_hash.merge!(ssnv_hash)

    bg = LexisNexisApi::BackgroundCheck.for_package(2117, bg_hash)
    xml = bg.to_xml

    assert_node xml, 'PackageId', :content => '2117'
    assert_node xml, 'PersonalData', :child => {:node_name => 'PersonName'}
    assert_node xml, 'PersonalData', :child => {:node_name => 'PostalAddress'}
    assert_node xml, 'PersonalData', :child => {:node_name => 'DemographicDetail', :child => {:node_name => 'GovernmentId'}}
    assert_node xml, 'PersonalData', :child => {:node_name => 'DemographicDetail', :child => {:node_name => 'DateOfBirth'}}
    assert_no_node xml, 'PersonalData', :child => {:node_name => 'Licenses'}
  end

  test '2168 should have correct parts' do
    bg_hash = background_check_hash(:account => '036483', :password => 'Password2')
    bg_hash[:person_names] << name_hash
    bg_hash[:postal_addresses] << address_hash
    bg_hash[:licenses] << license_hash
    bg_hash.merge!(ssnv_hash)

    bg = LexisNexisApi::BackgroundCheck.for_package(2168, bg_hash)
    xml = bg.to_xml

    assert_node xml, 'PackageId', :content => '2168'
    assert_node xml, 'PersonalData', :child => {:node_name => 'PersonName'}
    assert_node xml, 'PersonalData', :child => {:node_name => 'PostalAddress'}
    assert_node xml, 'PersonalData', :child => {:node_name => 'DemographicDetail', :child => {:node_name => 'GovernmentId'}}
    assert_node xml, 'PersonalData', :child => {:node_name => 'DemographicDetail', :child => {:node_name => 'DateOfBirth'}}
    assert_no_node xml, 'PersonalData', :child => {:node_name => 'Licenses'}
  end

  test '2169 should have correct parts' do
    bg_hash = background_check_hash(:account => '036483', :password => 'Password2')
    bg_hash[:person_names] << name_hash
    bg_hash[:postal_addresses] << address_hash
    bg_hash[:licenses] << license_hash
    bg_hash.merge!(ssnv_hash)

    bg = LexisNexisApi::BackgroundCheck.for_package(2169, bg_hash)
    xml = bg.to_xml

    assert_node xml, 'PackageId', :content => '2169'
    assert_node xml, 'PersonalData', :child => {:node_name => 'PersonName'}
    assert_node xml, 'PersonalData', :child => {:node_name => 'PostalAddress'}
    assert_node xml, 'PersonalData', :child => {:node_name => 'DemographicDetail', :child => {:node_name => 'GovernmentId'}}
    assert_node xml, 'PersonalData', :child => {:node_name => 'DemographicDetail', :child => {:node_name => 'DateOfBirth'}}
    assert_no_node xml, 'PersonalData', :child => {:node_name => 'Licenses'}
  end

  test '2360 should have correct parts' do
    bg_hash = background_check_hash(:account => '036483', :password => 'Password2')
    bg_hash[:person_names] << name_hash
    bg_hash[:postal_addresses] << address_hash
    bg_hash[:licenses] << license_hash
    bg_hash.merge!(ssnv_hash)

    bg = LexisNexisApi::BackgroundCheck.for_package(2360, bg_hash)
    xml = bg.to_xml

    assert_node xml, 'PackageId', :content => '2360'
    assert_node xml, 'PersonalData', :child => {:node_name => 'PersonName'}
    assert_node xml, 'PersonalData', :child => {:node_name => 'PostalAddress'}
    assert_node xml, 'PersonalData', :child => {:node_name => 'DemographicDetail', :child => {:node_name => 'GovernmentId'}}
    assert_node xml, 'PersonalData', :child => {:node_name => 'DemographicDetail', :child => {:node_name => 'DateOfBirth'}}
    assert_no_node xml, 'PersonalData', :child => {:node_name => 'Licenses'}
  end


end
