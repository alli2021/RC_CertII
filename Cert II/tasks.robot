*** Settings ***
Documentation   Template robot main suite.
Library         RPA.Browser.Selenium
Library         RPA.HTTP
Library         RPA.PDF
Library         RPA.Tables
Library         RPA.Word.Application
Library         RPA.Archive
Library         img2word
Library         RPA.FileSystem
Library         RPA.Robocloud.Secrets
Library         RPA.Dialogs
Variables       variables.py



# +
*** Variables ***

${GLOBAL_RETRY_AMOUNT}    3x
${GLOBAL_RETRY_INTERVAL}    0.5s
${RPA_SECRET_FILE}     ${CURDIR}${/}output${/}


# +
*** Keywords ***
Get User Input
    Create Form    User Input
    Add Text Input    Who is Ordering    search
    &{response}    Request Response
   # [Return]    ${response["search"]}
    Log  ${response["search"]}
    

# -

*** Keywords ***
Open Order Website
    Open Available Browser  https://robotsparebinindustries.com/#/robot-order
    Wait Until Page Contains Element    alias:popup.okay
    Maximize Browser Window


*** Keywords ***
Click Popup
    Wait Until Page Contains Element    alias:popup.okay
    Click Element       alias:popup.okay

*** Keywords ***
Download and Read CSV
    Download   https://robotsparebinindustries.com/orders.csv    overwrite=True
    @{order_list}=    Read table from CSV     orders.csv
   # Log   ${order_list}
    
    FOR    ${order}    IN     @{order_list}
             Input Order    ${order}
    END 

# +
*** Keywords ***

Get Vault Data and Log

    Log    ${USER_NAME}
    Log    ${PASSWORD}

# -



# +
*** Keywords ***
Input Order
    [Arguments]     ${order}
    Select From List By Index   alias:main.q1    ${order}[Head]
    Input Text    alias:main.q3    ${order}[Legs]
    Input Text    alias:main.add   ${order}[Address]
    
    IF   ${order}[Body]==1
    Click Element    alias:main.q2c1
    ELSE IF  ${order}[Body]==2
    Click Element    alias:main.q2c2
    ELSE IF  ${order}[Body]==3
    Click Element    alias:main.q2c3
    ELSE IF  ${order}[Body]==4
    Click Element    alias:main.q2c4    
    ELSE IF  ${order}[Body]==5
    Click Element    alias:main.q2c5
    ELSE IF  ${order}[Body]==6
    Click Element    alias:main.q2c6    
    
    END
    
    Click Element    alias:main.preview

    
    Wait Until Keyword Succeeds    8x   1s   Submit Order
    
    Get Receipt and Screenshot   ${order}
    
   
# -



# +
*** Keywords ***
Submit Order
        
    Click Element    alias:main.order
    
    Wait Until Element Is Visible    alias:result.header
    
    




# +
*** Keywords ***
Get Receipt and Screenshot
    [Arguments]     ${order}
    ${Receipt}=    Get Text     alias:result.receipt
    

    
    ${headurl} =  Catenate  https://robotsparebinindustries.com/heads/${order}[Head].png
    #${headname} =  Catenate  ${order}[Head].png
    ${bodyurl} =  Catenate  https://robotsparebinindustries.com/bodies/${order}[Body].png
    #${bodyname} =  Catenate  ${order}[Body].png
    ${legurl} =  Catenate  https://robotsparebinindustries.com/legs/${order}[Legs].png
    #${legname} =  Catenate  ${order}[Legs].png

    
    Download  ${headurl}   ${CURDIR}${/}output/head.png  overwrite=True
    Download  ${bodyurl}   ${CURDIR}${/}output/body.png  overwrite=True
    Download  ${legurl}    ${CURDIR}${/}output/leg.png   overwrite=True

    
    i2w  ${CURDIR}${/}output${/}result_word.docx  ${Receipt}   ${CURDIR}${/}output/head.png   ${CURDIR}${/}output/body.png   ${CURDIR}${/}output/leg.png

    
    Open Application    True    False
    Open File    ${CURDIR}${/}output${/}result_word.docx
    
    Create Directory   ${CURDIR}${/}output${/}final${/}

    
    Export To Pdf    ${CURDIR}${/}output${/}final${/}order_${order}[Order number]
        
    Quit Application    False
    
    Return to Order Page
        

    
# -



*** Keywords ***
Return to Order Page
    Click Element    alias:result.orderagain
    
    Click Popup

# +
*** Keywords ***
Close Order Form
    Close All Browsers



# -

*** Keywords ***
Zip PDF Receipts
   # ${Filelist}=  ${CURDIR}${/}output/final/
    

    Archive Folder With Zip    ${CURDIR}${/}output/final/     ${CURDIR}${/}output/Final.zip

# +
*** Keywords ***
Read Data from Vault


# -

*** Keywords ***
Seek Input from Human
    #authoriser name





*** Tasks ***
Order Robots
    Get User Input
    Get Vault Data and Log
    Open Order Website
    Click Popup
    Download and Read CSV
    Zip PDF Receipts
    [Teardown]   Close Order Form
    
    Log  Done.







# # 
