*** Settings ***
Library    RequestsLibrary
Library    Collections


*** Keywords ***

Validate Cat Fact Schema
    [Arguments]    ${item}    ${max_length}=None
    [Documentation]    Validate structure and consistency of a single cat fact item.
    Dictionary Should Contain Key    ${item}    fact
    Dictionary Should Contain Key    ${item}    length
    # Check that fact is a string 
    ${fact} =    Set Variable    ${item['fact']}
    ${is_str} =    Evaluate    isinstance($fact, str)
    Should Be True    ${is_str}
    # Check that length is an integer
    ${length} =  Set Variable    ${item['length']}   
    ${is_int} =  Evaluate    isinstance($length, int)
    Should Be True    ${is_int}
    # Check that length matches actual fact length
    ${fact_len} =    Evaluate    len($fact)
    Run Keyword If     ${length} != ${fact_len}    Log    Length mismatch! Expected: ${length}, Actual: ${fact_len}, Fact: ${fact}
    Should Be Equal As Integers    ${length}    ${fact_len} 


Get Random Fact
    [Documentation]    Perform GET request to /fact endpoint
    ${response} =    GET On Session    catfact    /fact  
    Log To Console    \n[REQUEST] GET /fact
    Log To Console    Status: ${response.status_code}
    RETURN            ${response}


Get Random Fact With Max Length
    [Arguments]    ${max_length}
    [Documentation]    Perform GET request to /fact endpoint with max_length parameter
    ${params}=    Create Dictionary    max_length=${max_length}
    ${response}=   GET On Session    catfact    /fact    params=${params}
    Log To Console    \n[REQUEST] GET /fact?max_length=${max_length}
    Log To Console    Status Code: ${response.status_code}
    RETURN   ${response}


Get Facts With Limit
    [Arguments]    ${limit}
    [Documentation]    Perform GET request to /facts endpoint with a limit parameter
    ${params} =        Create Dictionary                      limit=${limit}
    ${response} =     GET On Session    catfact    /facts    params=${params}
    Log To Console    \n[REQUEST] GET /facts?limit=${limit}
    Log To Console    Status: ${response.status_code} 
    RETURN             ${response}    


Get Facts Without Limit
    [Documentation]    Perform GET request to /facts endpoint without a limit parameter
    ${response}=    GET On Session    catfact    /facts
    Log To Console    \n[REQUEST] GET /facts (no limit)
    Log To Console    Status: ${response.status_code}
    RETURN    ${response}


Get Facts With Max Length
    [Arguments]    ${max_length}
    [Documentation]    Perform GET request to /facts endpoint with max_length parameter
    ${params}=    Create Dictionary    max_length=${max_length}
    ${response}=  GET On Session    catfact    /facts    params=${params}
    Log To Console    \n[REQUEST] GET /facts?max_length=${max_length}
    Log To Console    Status Code: ${response.status_code}
    RETURN   ${response}


Get Facts With Max_length and Limit
    [Arguments]    ${max_length}=None    ${limit}=None
    [Documentation]    Get facts from /facts endpoint with optional limit and max_length parameters
    ${params}=    Create Dictionary
    # Add parameters only if provided
    Run Keyword If    ${limit} != None         Set To Dictionary    ${params}    limit=${limit}
    Run Keyword If    ${max_length} != None    Set To Dictionary    ${params}    max_length=${max_length}
    ${response}=    GET On Session    catfact    /facts    params=${params}
    Log To Console    \n[REQUEST] GET /facts with params: ${params}
    Log To Console    Status Code: ${response.status_code}
    RETURN    ${response}


