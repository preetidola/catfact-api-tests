*** Settings ***
Library    RequestsLibrary
Library    Collections


*** Keywords ***

Validate Cat Fact Schema
    [Arguments]    ${item}    ${max_length}=None
    Dictionary Should Contain Key    ${item}    fact
    Dictionary Should Contain Key    ${item}    length

    # Check that fact is a string 
    Log To Console    Validating that 'fact' is a string
    ${fact} =    Set Variable    ${item['fact']}
    ${is_str} =    Evaluate    isinstance($fact, str)
    Should Be True    ${is_str}
   
    # Check that length is an integer
    Log To Console    Validating that 'length' is an integer
    ${length} =  Set Variable    ${item['length']}   
    ${is_int} =    Evaluate    isinstance($length, int)
    Should Be True    ${is_int}

    # Check that length matches actual fact length
    Log To Console    Validating that 'length' matches actual fact length
    ${fact_len} =    Evaluate    len($fact)
    Should Be Equal As Integers    ${length}    ${fact_len} 
    
Get Random Fact
    [Documentation]    Perform GET request to /fact endpoint
     ${response} =    get    https://catfact.ninja/fact  
    Log To Console      \n[REQUEST] GET /fact
    Log To Console    Status: ${response.status_code}
    Log To Console    Body: ${response.text}3
    Log               ${response.text}    
    RETURN            ${response}

Get Random Fact With Max Length
    [Arguments]    ${max_length}
    [Documentation]    Perform GET request to /fact endpoint with max_length
    ${params}=    Create Dictionary    max_length=${max_length}
    ${response}=   get     https://catfact.ninja/fact    params=${params}
    Log To Console    \n[DEBUG] GET /fact?max_length=${max_length}
    Log To Console    Status Code: ${response.status_code}
    Log To Console    Response Body: ${response.text}
    RETURN   ${response}

Get Facts With Limit
    [Arguments]    ${limit}
    [Documentation]    Perform GET request to /facts endpoint with a limit
    ${exists}=    Run Keyword And Return Status    Session Exists    catfact
    IF    not ${exists}
        Create Session    catfact    https://catfact.ninja
    END
    ${params} =        Create Dictionary                      limit=${limit}
    ${response} =      get     https://catfact.ninja/facts    params=${params}
    Log To Console    \n[REQUEST] GET /facts?limit=${limit}
    Log To Console    Status: ${response.status_code}
    Log To Console    Body: ${response.text}
    Log    ${response.text}
    RETURN             ${response}    

Get Facts Without Limit
    [Documentation]    Perform GET request to /facts endpoint without a limit parameter
    ${exists}=    Run Keyword And Return Status    Session Exists    catfact
    IF    not ${exists}
        Create Session    catfact    https://catfact.ninja
    END
    ${response}=    get    https://catfact.ninja/facts
    Log To Console    \n[REQUEST] GET /facts (no limit)
    Log To Console    Status: ${response.status_code}
    Log To Console    Body: ${response.text}
    RETURN    ${response}

Get Facts With Max Length
    [Arguments]    ${max_length}
    [Documentation]    Perform GET request to /facts endpoint with max_length
    ${params}=    Create Dictionary    max_length=${max_length}
    ${response}=   get     https://catfact.ninja/facts    params=${params}
    Log To Console    \n[DEBUG] GET /facts?max_length=${max_length}
    Log To Console    Status Code: ${response.status_code}
    Log To Console    Response Body: ${response.text}
    RETURN   ${response}

Get Facts With Max_length and Limit
    [Arguments]    ${max_length}=None    ${limit}=None
   [Documentation]    Get facts from /facts endpoint with optional limit and max_length
    ${params}=    Create Dictionary

    # Add parameters only if provided
    Run Keyword If    ${limit} != None         Set To Dictionary    ${params}    limit=${limit}
    Run Keyword If    ${max_length} != None    Set To Dictionary    ${params}    max_length=${max_length}

    ${response}=     get     https://catfact.ninja/facts    params=${params}
    Log To Console    \n[DEBUG] GET /facts with params: ${params}
    Log To Console    Status Code: ${response.status_code}
    Log To Console    Response Body: ${response.text}
    RETURN    ${response}

Log Fact Details
    [Arguments]    @{facts}
    FOR    ${item}    IN    @{facts}
        Log To Console    Fact: ${item['fact']}
        Log To Console    Length: ${item['length']}
    END
