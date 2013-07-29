module LexisNexisApi

  module XmlSamples

    CHANGE_PASSWORD_COMPLETE_RESPONSE = %q[<?xml version="1.0" encoding="UTF-8"?>
<soapenv:Envelope
    xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:cp="http://www.cpscreen.com/schemas"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <soapenv:Body>
    <ChoicePointAdminResponse xmlns="http://www.cpscreen.com/schemas">
      <ChangePassword>
        <Status>Complete</Status>
        <Account>036483</Account>
        <UserId>XCHANGE</UserId>
        <Password>This should be right</Password>
        <NewPassword>hC0^eL0@sK9@aN7^mV4#iT6(cM0!vG1(cH8#aO8@</NewPassword>
      </ChangePassword>
    </ChoicePointAdminResponse>
  </soapenv:Body>
</soapenv:Envelope>
    ]

    CHANGE_PASSWORD_FAIL_RESPONSE = %q[<?xml version="1.0" encoding="UTF-8"?>
<soapenv:Envelope
    xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:cp="http://www.cpscreen.com/schemas"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <soapenv:Body>
    <ChoicePointAdminResponse xmlns="http://www.cpscreen.com/schemas">
      <ChangePassword>
        <Status>Fail</Status>
        <Account>036483</Account>
        <UserId>XCHANGE</UserId>
        <Password>This should be wrong</Password>
        <NewPassword>hC0^eL0@sK9@aN7^mV4#iT6(cM0!vG1(cH8#aO8@</NewPassword>
        <Error>
          <ErrorCode>250</ErrorCode>
          <ErrorDescription>Invalid old password</ErrorDescription>
        </Error>
      </ChangePassword>
    </ChoicePointAdminResponse>
  </soapenv:Body>
</soapenv:Envelope>
    ]

  end
end
