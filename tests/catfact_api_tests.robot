*** Settings ***
Documentation     Test suite for CatFact API using Robot Framework
Library           RequestsLibrary
Library           Collections
Library           String
Resource          ../resources/api_keywords.robot

Suite Setup    Create Session    catfact    ${BASE_URL}

*** Variables ***
${BASE_URL}       https://catfact.ninja
${MAX_LENGTH}     4
${LIMIT}          3    


*** Test Cases ***
Verify GET /fact returns 200
    ${response} =   Get Random Fact
    Log    ${response.status_code}
    Log    ${response.text}
    Should Be Equal As Integers    ${response.status_code}    200

Verify /fact response structure
    ${response} =  Get Random Fact
    ${json} =      Set Variable     ${response.json()}
    Validate Cat Fact Schema        ${json}

Verify /fact with max_length parameter
    ${response}=    Get Random Fact With Max Length    ${MAX_LENGTH}
    Should Be Equal As Integers    ${response.status_code}    200

    ${json}=    Set Variable    ${response.json()}

    IF    '${json}' == '{}'
        Log To Console    [INFO] No fact available with max_length=${MAX_LENGTH}
    ELSE
        Log To Console    [DEBUG] Random fact returned: ${json['fact']}
        Log To Console    [DEBUG] Fact length: ${json['length']}, Max allowed: ${MAX_LENGTH}
        # Verify that fact length is <= max_length
        Should Be True    ${json['length']} <= ${max_length}    Random fact exceeds max_length
    END

Verify GET /facts returns 200
    ${response} =   Get Facts With Limit    ${LIMIT}  
    Should Be Equal As Integers    ${response.status_code}    200

Verify /facts items structure and response schema
    ${response} =    Get Facts With Limit    3
    Should Be Equal As Integers    ${response.status_code}    200

    ${json} =        Set Variable   ${response.json()}
    Log To Console    \n[DEBUG] Full JSON: ${json}

    # Validate top-level keys exist
    Dictionary Should Contain Key    ${json}    data
    Dictionary Should Contain Key    ${json}    total
    Dictionary Should Contain Key    ${json}    per_page
    Dictionary Should Contain Key    ${json}    last_page

    # Validate data is a list
    ${data}=    Set Variable    ${json['data']}
    Should Be True    isinstance(${data}, list)

    # Validate per_page and total fields
    Should Be True    ${json['total']} >= 0
    Should Be Equal As Integers    ${json['per_page']}    3
    
    # Loop through data and validate schema for each item
    FOR    ${item}    IN    @{data}
        Validate Cat Fact Schema    ${item}
    END

Verify /facts with limit parameter
    ${response} =   Get Facts With Limit    ${LIMIT} 
    Log To Console    \n[DEBUG] Status Code: ${response.status_code}

    # Check status
    Should Be Equal As Integers    ${response.status_code}    200
    
    # Parse JSON response
    ${json}=    Set Variable    ${response.json()}
    Log To Console    [DEBUG] Full JSON: ${json}

    # Extract data list
    ${data}=    Set Variable    ${json['data']}
    ${data_length}=    Get Length    ${data}
    Log To Console    [DEBUG] Number of facts returned: ${data_length}
    Log To Console    [DEBUG] Facts: ${data}

    # Validate number of facts should be less than the limit
    Should Be True    ${data_length} <= ${LIMIT}    Returned more facts than limit

    # Check total
    Dictionary Should Contain Key    ${json}    total
    Log To Console    [DEBUG] Total facts available: ${json['total']}
    Should Be True    ${json['total']} >= 0

    # Validate per_page matches limit
    Log To Console    [DEBUG] Last page returned by API: ${json['per_page']}
    Dictionary Should Contain Key    ${json}    per_page
    Should Be Equal As Integers    ${json['per_page']}    ${limit}

    # Calculate expected last page (ceiling division)
    Dictionary Should Contain Key    ${json}    last_page
    Log To Console    [DEBUG] Last page returned by API: ${json['last_page']}
    ${expected_last_page}=    Evaluate    -(-${json['total']} // ${limit})   # ceiling division
    Log To Console    [DEBUG] Expected last page based on total and limit: ${expected_last_page}
    
    #Validate last_page is consistent with total and limit
    Should Be Equal As Integers    ${json['last_page']}    ${expected_last_page}
    

Verify /facts with max_length parameter
    ${response}=    Get Facts With Max Length    ${MAX_LENGTH}
   Should Be Equal As Integers    ${response.status_code}    200

    ${json}=    Set Variable    ${response.json()}
    ${data}=    Set Variable    ${json['data']}
    ${data_length}=    Get Length    ${data}
    Log To Console    [DEBUG] Number of facts returned: ${data_length}
    Log To Console    [DEBUG] Facts: ${data}

    # Verify each fact's length <= max_length
    FOR    ${item}    IN    @{data}
          Should Be True    ${item['length']} <= ${MAX_LENGTH}    Fact "${item['fact']}" exceeds max_length
          Log To Console    [DEBUG] Fact OK (length ${item['length']}): ${item['fact']}
    END
    # Validate pagination fields
    Log To Console    [DEBUG] Per page: ${json['per_page']}, Total: ${json['total']}, Last page: ${json['last_page']}


Verify /facts with limit and max_length together
    ${response}=    Get Facts With Max_length and Limit     ${MAX_LENGTH}   ${LIMIT} 
    Should Be Equal As Integers    ${response.status_code}    200

    ${json}=          Set Variable    ${response.json()}
    ${data}=          Set Variable    ${json['data']}
    ${data_length}=   Get Length      ${data}
    
    #If the test fails, it will show the message: "Returned more facts than limit".
    Should Be True    ${data_length} <= ${LIMIT}    Returned more facts than limit
    FOR    ${item}    IN    @{data}
       #If the test fails, it will show the message:,"Fact exceeds max_length"
       Should Be True    ${item['length']} <= ${MAX_LENGTH}    Fact exceeds max_length
       Log To Console    [DEBUG] Fact OK (length ${item['length']}): ${item['fact']}
    END


Verify Default Facts When Limit Is Zero 
    [Documentation]    When limit = 0, the API should return 10 facts by default.     
    ${response}=    Get Facts With Limit    0
    ${json}=        Set Variable    ${response.json()}

    # Validate data length
    ${data}=        Set Variable    ${json['data']}
    ${data_length}=    Get Length    ${data}
    Should Be True    ${data_length} <= 10    Returned more than 10 facts when limit=0

    # Validate per_page
    Should Be Equal As Integers    ${json['per_page']}    10    per_page should be 10

Verify Default Facts When Limit Is Negative
    ${response}=    Get Facts With Limit    -5
    ${json}=        Set Variable    ${response.json()}
    ${data}=        Set Variable    ${json['data']}
    ${data_length}=    Get Length    ${data}
    Should Be True    ${data_length} <= 10     Returned more than 10 facts when limit =-5
    # Validate per_page
    Should Be Equal As Integers    ${json['per_page']}    10    per_page should be 10

Verify Default Facts When Limit Is Missing
    ${response}=    Get Facts Without Limit
    ${body}=        Set Variable    ${response.json()}
    ${data}=        Set Variable    ${body['data']}
    ${data_length}=    Get Length    ${data}
    Should Be True    ${data_length} <= 10      Returned more than 10 facts
    Should Be Equal As Integers    ${body['per_page']}    10