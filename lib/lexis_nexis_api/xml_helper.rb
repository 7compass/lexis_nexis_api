
module LexisNexisApi

  module XmlHelper

    def soap_wrapper(xml)
      %Q{<?xml version="1.0"?>
<soapenv:Envelope
    xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <soapenv:Body>
  #{strip_instruct(xml)}
  </soapenv:Body>
</soapenv:Envelope>
      }
    end

    def strip_instruct(xml)
      xml.gsub!(%r{<\?xml\s+version=['"]1.0['"]\s*\?>}, '')
      xml
    end

  end

end