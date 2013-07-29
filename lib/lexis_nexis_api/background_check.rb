
require 'nokogiri'

module LexisNexisApi

  class BackgroundCheck
    extend XmlHelper

    # 
    # PRI-FAM:
    # PRI-FFM:
    # PRI-FIM:
    # PRINCRF:
    # PRINCRP:
    #   PersonalData/PersonName
    #   PersonalData/PostalAddress
    # 
    # SSNV:
    #   PersonalData/DemographicDetail
    # 
    # MVR:
    #   PersonalData/Licenses
    # 
    
    
    # combos
    #  2112 = Package 1 = PRI-FIM, PRINCRF, PRINCRP, SSNV
    #  2113 = Package 2 = PRI-FAM, PRINCRP, SSNV
    #  2114 = Package 3 = MVR, PRINCRP, SSNV
    #
    # ala carte
    #  2116 = Package 5 = MVR only
    #  2117 = Package 6 = PRINCRP
    #  2168 = Package 7 = PRI-FFM, SSNV
    #  2169 = Package 9 = PRI-FFM
    #  2360 = Package 14 = PRI-FAM
    #
    #
    #  2011-02-22:
    #  Package 1 can logically be ordered with 5,9 & 14
    #  Package 2 can logically be ordered with 5 & 9
    #  Package 3 can logically be ordered with 9 & 14
    #  Any combination of 5,6,7,9 & 14 could be ordered.
    #
    #
    def self.for_package(package_id, options)
      package_id = package_id.to_i
      
      background_check = self.new(options.merge(:package_id => package_id))

      background_check.add_ssnv # required for one-step orders

      background_check.add_name_and_address if [2112, 2113, 2114, 2116, 2117, 2168, 2169, 2360].include?(package_id)
      background_check.add_mvr if [2114, 2116].include?(package_id)
      
      background_check
    end

    def initialize(options={})
      @options = options
      @xml = create_root
      self
    end

    # 
    #  <BackgroundCheck
    #      xmlns="http://www.cpscreen.com/schemas"
    #      userId="XCHANGE"
    #      account="#{@account}"
    #      password="#{@password}">
    #    <BackgroundSearchPackage xmlns="">
    #      <PackageInformation>
    #        <PositionAppliedFor>Current InterVarsity Staff</PositionAppliedFor>
    #        <PackageId>#{options[:package_id]}</PackageId>
    #        <ClientReferences>
    #          <ClientReference>Region: Graduate &amp; Faculty Ministry North Atlantic</ClientReference>
    #          <ClientReference>Washington, DC</ClientReference>
    #        </ClientReferences>
    #        <OrderAccount>
    #          <UserId></UserId>
    #          <Account></Account>
    #        </OrderAccount>
    #      </PackageInformation>
    #      <PersonalData>
    #        <ContactMethod>
    #          <InternetEmailAddress></InternetEmailAddress>
    #        </ContactMethod>
    #      </PersonalData>
    #    </BackgroundSearchPackage>
    #  </BackgroundCheck>
    # 
    def create_root
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.BackgroundCheck(
          :xmlns => 'http://www.cpscreen.com/schemas',
          :userId => 'XCHANGE',
          :account => @options[:account],
          :password => @options[:password]
        ){
          xml.BackgroundSearchPackage(:xmlns => ''){
            xml.PackageInformation{
              xml.PositionAppliedFor @options[:position_applied_for]
              xml.PackageId @options[:package_id]
              xml.ClientReferences{
                xml.ClientReference @options[:client_reference1]
                xml.ClientReference @options[:order_as_user_id]
              }
              xml.OrderAccount{
                xml.UserId 'XCHANGE'
                xml.Account "#{@options[:account]}#{@options[:order_as_account_suffix]}"
              } if @options[:order_as_account_suffix]
            }
            xml.PersonalData{
              xml.ContactMethod{
                xml.InternetEmailAddress @options[:contact_email]
              }
            }
          }
        }
      end

      builder.to_xml
    end

    #
    # Optional element:
    # /BackgroundCheck/BackgroundSearchPackage/PersonalData/Licenses
    #
    # Contains 0*
    # /BackgroundCheck/BackgroundSearchPackage/PersonalData/Licenses/License
    #
    # options should contain:
    #   licenses:  an array of license info hashes
    #
    # license info hash:
    #   :valid_from      datetime or string YYYY-MM-DD
    #   :valid_to        datetime or string YYYY-MM-DD
    #   :country_code    2 char ISO country code
    #   :license_number  AN 1..20
    #   :license_region  2 char State/Region
    #
    def add_mvr
      builder = Nokogiri::XML::Builder.with(personal_data_node) do |xml|
        xml.Licenses {
          @options[:licenses].each do |hash|
            xml.License(:validFrom => ymd(hash[:valid_from]), :validTo => ymd(hash[:valid_to])) {
              xml.CountryCode(hash[:country_code])
              xml.LicenseNumber(hash[:license_number])
              xml.LicenseName 'mvr'
              xml.LicenseDescription 'mvr'
              xml.LicenseRegion hash[:license_region] # State
            }
          end
        }
      end

      @xml = builder.to_xml
    end

    # 
    # expects an array of :person_names in @options
    # expects an array of :postal_addresses in @options
    #
    #  <PersonName type="subject|alias">
    #    <GivenName>Kevin</GivenName>
    #    <MiddleName>Fred</MiddleName>
    #    <FamilyName>Test</FamilyName>
    #  </PersonName>
    #  <PostalAddress type="current|prior" validFrom="2009-01-01">
    #    <Municipality>Madison</Municipality>
    #    <Region>WI</Region>
    #    <PostalCode>53711</PostalCode>
    #    <CountryCode>US</CountryCode>
    #    <DeliveryAddress>
    #      <AddressLine>1234 Main Rd</AddressLine>
    #    </DeliveryAddress>
    #  </PostalAddress>
    def add_name_and_address
      builder = Nokogiri::XML::Builder.with(personal_data_node) do |xml|
        @options[:person_names].each do |hash|
          xml.PersonName(:type => hash[:type]){
            xml.GivenName hash[:first_name]
            xml.MiddleName hash[:middle_name]
            xml.FamilyName hash[:last_name]
          }
        end if @options[:person_names]

        @options[:postal_addresses].each do |hash|
          xml.PostalAddress(:type => hash[:type], :validFrom => ymd(hash[:valid_from]), :validTo => ymd(hash[:valid_to])){
            xml.Municipality hash[:municipality]
            xml.Region hash[:region]
            xml.PostalCode hash[:postal_code]
            xml.CountryCode hash[:country_code]
            xml.DeliveryAddress{
              xml.AddressLine hash[:address1]
              xml.AddressLine(hash[:address2]) if hash[:address2].present?
            }
          }
        end if @options[:postal_addresses]
      end

      @xml = builder.to_xml
    end

    #  <DemographicDetail>
    #    <GovernmentId issuingAuthority="SSN">123456789</GovernmentId>
    #    <DateOfBirth>1950-01-01</DateOfBirth>
    #  </DemographicDetail>
    #
    def add_ssnv
      builder = Nokogiri::XML::Builder.with(personal_data_node) do |xml|
        xml.DemographicDetail{
          xml.GovernmentId(@options[:ssn], :issuingAuthority => 'SSN')
          xml.DateOfBirth(ymd(@options[:date_of_birth]))
        }
      end

      @xml = builder.to_xml
    end

    def to_xml
      self.class.soap_wrapper(@xml)
    end

    protected

    def doc
      Nokogiri::XML(@xml)
    end

    def personal_data_node
      doc.at('//xmlns:BackgroundCheck/BackgroundSearchPackage/PersonalData', 'xmlns' => 'http://www.cpscreen.com/schemas')
    end

    # expects a Time or DateTime
    def ymd(date)
      return date if date.is_a?(String)
      date.strftime("%Y-%m-%d") if date
    end

    
    module XML

      SAMPLE_ORDER_RESPONSE = %Q{<?xml version="1.0" encoding="UTF-8"?>
<soapenv:Envelope
    xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:cp="http://www.cpscreen.com/schemas"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <soapenv:Body>
    <BackgroundReports xmlns="http://www.cpscreen.com/schemas">
      <BackgroundReportPackage type="report">
        <ProviderReferenceId>WPS-6266154</ProviderReferenceId>
        <PackageInformation>
          <ClientReferences>
            <ClientReference>Youth123456</ClientReference>
            <ClientReference>CN=Youth Tester/O=Youth</ClientReference>
          </ClientReferences>
          <Quotebacks>
            <Quoteback name="Youth-83SQ7J"/>
          </Quotebacks>
        </PackageInformation>
        <PersonalData>
          <PersonName type="subject">
            <GivenName>Test</GivenName>
            <FamilyName>Youth</FamilyName>
          </PersonName>
          <DemographicDetail>
            <GovernmentId issuingAuthority="SSN">123456789</GovernmentId>
            <DateOfBirth/>
            <Gender>F</Gender>
          </DemographicDetail>
        </PersonalData>
        <ScreeningStatus>
          <OrderStatus>InProgress</OrderStatus>
        </ScreeningStatus>
        <ScreeningResults mediaType="html">
          <InternetWebAddress>https://screentest.lexisnexis.com/pub/l/login/userLogin.do?referer=https://screentest.lexisnexis.com/pub/l/jsp/menu/orderViewingMenuFrameSet.jsp?key=123|ABCDEFG</InternetWebAddress>
        </ScreeningResults>
      </BackgroundReportPackage>
    </BackgroundReports>
  </soapenv:Body>
</soapenv:Envelope>
      }

      SAMPLE_USER_LOCKED_RESPONSE = %q[<?xml version="1.0" encoding="UTF-8"?>
<soapenv:Envelope
    xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:cp="http://www.cpscreen.com/schemas"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <soapenv:Body>
    <BackgroundReports xmlns="http://www.cpscreen.com/schemas">
      <BackgroundReportPackage type="errors">
        <ErrorReport>
          <ErrorCode>210</ErrorCode>
          <ErrorDescription>User is locked</ErrorDescription>
        </ErrorReport>
      </BackgroundReportPackage>
    </BackgroundReports>
  </soapenv:Body>
</soapenv:Envelope>
      ]
  
    end # module XML

  end # class BackgroundCheck

end