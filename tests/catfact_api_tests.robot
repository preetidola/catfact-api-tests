*** Settings ***
Documentation     Test suite for CatFact API using Robot Framework
Library           RequestsLibrary
Library           Collections
Library           String
Resource          ../resources/api_keywords.robot

Suite Setup    Create Session    catfact    ${BASE_URL}

*** Variables ***
${BASE_URL}       https://catfact.ninja
${MAX_LENGTH}     400
${LIMIT}          116 


*** Test Cases ***
Verify GET /fact returns 200
    ${response} =   Get Random Fact
    Should Be Equal As Integers    ${response.status_code}    200

Verify /fact response structure
    ${response} =  Get Random Fact
    ${json} =      Set Variable     ${response.json()}
    Validate Cat Fact Schema        ${json}

Verify /fact with max_length parameter
    ${response}=    Get Random Fact With Max Length    ${MAX_LENGTH}
    Should Be Equal As Integers    ${response.status_code}    200

    ${json}=    Set Variable    ${response.json()}

    IF    ${json} != '{}'
        # Verify fact length does not exceed max_length
        Should Be True    ${json['length']} <= ${MAX_LENGTH}    Random fact ${json['length']} exceeds max_length ${MAX_LENGTH}
    END

Verify GET /facts returns 200
    ${response} =   Get Facts With Limit    ${LIMIT}  
    Should Be Equal As Integers    ${response.status_code}    200

Verify /facts items structure and response schema
    ${response} =    Get Facts With Limit    ${LIMIT}
    Should Be Equal As Integers    ${response.status_code}    200
    ${json} =        Set Variable   ${response.json()}
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
    ${effective_limit}=    Evaluate    ${LIMIT} if ${LIMIT} > 0 else 10
    Should Be Equal As Integers    ${json['per_page']}    ${effective_limit}
    # Loop through data and validate schema for each item
    FOR    ${item}    IN    @{data}
        Validate Cat Fact Schema    ${item}
    END

Verify /facts with limit parameter
    ${response} =   Get Facts With Limit    ${LIMIT} 
    Should Be Equal As Integers    ${response.status_code}    200
    ${json}=    Set Variable    ${response.json()}
    ${data}=    Set Variable    ${json['data']}
    ${data_length}=    Get Length    ${data}
    # Handle API default behavior for limit <= 0
    ${effective_limit}=    Evaluate    ${LIMIT} if ${LIMIT} > 0 else 10
    # Validate number of facts does not exceed limit
    Should Be True    ${data_length} <= ${effective_limit}    Returned more facts than limit
    # Validate total exists and is non-negative
    Dictionary Should Contain Key    ${json}    total
    Should Be True    ${json['total']} >= 0
    # Validate per_page matches the effective limit
    Dictionary Should Contain Key    ${json}    per_page
    Should Be Equal As Integers    ${json['per_page']}    ${effective_limit}
    # Validate last_page calculation
    Dictionary Should Contain Key    ${json}    last_page
    ${expected_last_page}=    Evaluate    -(-${json['total']} // ${effective_limit})   
    #Validate last_page is consistent with total and limit
    Should Be Equal As Integers    ${json['last_page']}    ${expected_last_page}
    

Verify /facts with max_length parameter
    ${response}=    Get Facts With Max Length    ${MAX_LENGTH}
    Should Be Equal As Integers    ${response.status_code}    200
    ${json}=    Set Variable    ${response.json()}
    ${data}=    Set Variable    ${json['data']}
    ${data_length}=    Get Length    ${data}
    # Verify fact length does not exceed max_length
    FOR    ${item}    IN    @{data}
          Should Be True    ${item['length']} <= ${MAX_LENGTH}    Fact "${item['fact']}" exceeds max_length
    END
    
    
Verify /facts with limit and max_length together
    ${response}=    Get Facts With Max_length and Limit     ${MAX_LENGTH}   ${LIMIT} 
    Should Be Equal As Integers    ${response.status_code}    200
    ${json}=          Set Variable    ${response.json()}
    ${data}=          Set Variable    ${json['data']}
    ${data_length}=   Get Length      ${data}
    # Handle default limit behavior
    ${effective_limit}=    Evaluate    ${LIMIT} if ${LIMIT} > 0 else 10
    Should Be True    ${data_length} <= ${effective_limit}    Returned more facts than limit
    # Validate each fact length
    FOR    ${item}    IN    @{data}
       Validate Cat Fact Schema    ${item}
       Should Be True    ${item['length']} <= ${MAX_LENGTH}    Fact exceeds max_length
    END


Verify Default Facts When Limit Is Zero 
    [Documentation]    When limit = 0, the API should return 10 facts by default.     
    ${response}=    Get Facts With Limit    0
    Should Be Equal As Integers    ${response.status_code}    200
    ${json}=        Set Variable    ${response.json()}
    ${data}=        Set Variable    ${json['data']}
    ${data_length}=    Get Length    ${data}
    Should Be True    ${data_length} <= 10    Returned more than 10 facts 
    # Validate per_page
    Should Be Equal As Integers    ${json['per_page']}    10    per_page should be 10


Verify Default Facts When Limit Is Negative
    [Documentation]    When limit < 0, the API should return 10 facts by default.
    ${response}=    Get Facts With Limit    -5
    Should Be Equal As Integers    ${response.status_code}    200
    ${json}=        Set Variable    ${response.json()}
    ${data}=        Set Variable    ${json['data']}
    ${data_length}=    Get Length    ${data}
    Should Be True    ${data_length} <= 10     Returned more than 10 facts
    # Validate per_page
    Should Be Equal As Integers    ${json['per_page']}    10    per_page should be 10

Verify Default Facts When Limit Is Missing
    [Documentation]    When limit parameter is missing, API should return 10 facts by default.
    ${response}=    Get Facts Without Limit
    Should Be Equal As Integers    ${response.status_code}    200
    ${json}=        Set Variable    ${response.json()}
    ${data}=        Set Variable    ${json['data']}
    ${data_length}=    Get Length    ${data}
    Should Be True    ${data_length} <= 10      Returned more than 10 facts
    Should Be Equal As Integers    ${json['per_page']}    10