require 'rubygems'

ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "../../../../../config/environment")
require 'test_help'

require 'test/unit'
require 'active_support'
require 'active_support/test_case'
require File.dirname(__FILE__) + '/../lib/lexis_nexis_api'
require File.dirname(__FILE__) + '/../lib/lexis_nexis_api/xml_samples'
require 'rexml/document'

def address_hash(options={})
  {
    :type => 'current',
    :valid_from => '2010-01-02',
    :valid_to => '2020-12-31',
    :municipality => 'Madison',
    :region => 'WI',
    :postal_code => '53711',
    :country_code => 'US',
    :address1 => '1234 Main St',
    :address2 => '',
  }.merge(options)
end


#
# xml:  the XML string to search
#
# node_name:  the name of the node to find in given XML
#
# options:
#   :attributes => { :attr_name => :attr_value }
#
#   :content => 'content of this node'
#
#   :child => {
#     :node_name => 'ChildNodeName',
#     :attributes => { :attr_name => :attr_value },
#     :content => 'Child content'
#   }
#
def assert_node(xml, node_name, options={})
  # we're using REXML here because it seems that neither Nokogiri nor Hpricot
  # parse the multi-element XPath query properly, returning false positives.
  # I did validate the query against an external XPath validator too.
  doc = REXML::Document.new(xml)
  q = xpath_query_for(node_name, options)
  assert REXML::XPath.match(doc, q).size > 0, "Could not find < #{q} > in:\n#{xml}"
end

def assert_no_node(xml, node_name, options={})
  doc = REXML::Document.new(xml)
  q = xpath_query_for(node_name, options)
  assert REXML::XPath.match(doc, q).empty?, "Expected not to find < #{q} > in:\n#{xml}"
end

def background_check_hash(options={})
  {
    :account => '123456',
    :password => 'Secret',
    :position_applied_for => 'Pastor',
    :package_id => '2112',
    :client_reference1 => '',
    :client_reference2 => '',
    :order_as_user_id => 'joeuser',
    :order_as_account_suffix => 'TST',
    :contact_email => 'me@example.com',
    :licenses => [],
    :person_names => [],
    :postal_addresses => [],
  }.merge(options)
end

def license_hash(options={})
  {
    :valid_from => '2001-02-03',
    :valid_to => '2004-05-06',
    :country_code => 'US',
    :license_number => 'A1B2C3D4',
    :license_region => 'CA',
  }.merge(options)
end

def name_hash(options={})
  {
    :type => 'subject',
    :first_name => 'Joe',
    :middle_name => 'X',
    :last_name => 'Tester',
  }.merge(options)
end

def ssnv_hash(options={})
  {
    :ssn => '123456789',
    :date_of_birth => '1950-01-02'
  }.merge(options)
end

#
# constructs an XPath query like:
#   //License[@validFrom="1999-01-01" and @validTo="2001-02-03"]
#
#   or
#
#   //LicenseNumber[.="1234ABC"]
#
#   or
#
#   //PersonName[@type="subject"]/GivenName[.="First1"]
#
def xpath_query_for(node_name, options={})
  xpath_query = "#{options[:is_child] ? '/' : '//'}#{node_name}"
  extras = []
  extras += [%Q{.="#{options[:content]}"}] if options[:content]

  extras += options[:attributes].map do |k,v|
    %Q{@#{k}="#{v}"}
  end if options[:attributes]

  xpath_query << "[#{extras.join(' and ')}]" unless extras.empty?

  if options[:child]
    child = options.delete(:child)
    child_options = {
      :is_child => true,
      :attributes => child[:attributes],
      :content => child[:content],
      :child => child[:child]
    }
    return xpath_query << "#{xpath_query_for(child[:node_name], child_options)}"
  else
    xpath_query
  end
end

def xtest(*args)
  file = File.basename(caller.first)
  puts "Disabled test [#{file}]: #{args.first}"
end
