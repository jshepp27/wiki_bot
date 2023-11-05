*** Settings ***
Documentation     Scrape a Wikipedia page for text and references hyperlinks.
Library           RPA.Browser.Selenium
Suite Setup       Open Browser To Wikipedia Page
Suite Teardown    Close Browser
Library           Collections
Library           OperatingSystem
Library           String

*** Variables ***
${WIKIPEDIA_URL}    https://en.wikipedia.org/wiki/Cohere
${TEXT_FILE_NAME}     wiki_text.txt
${LINKS_FILE_NAME}    links.txt 

*** Keywords ***
Open Browser To Wikipedia Page
    Open Available Browser    ${WIKIPEDIA_URL}
    Maximize Browser Window

Extract Text
    [Documentation]    Extracts the main text from the Wikipedia page, excluding references.
    ${content}=    Get Text    css=#mw-content-text
    @{references_elements}=    Get Webelements    css=#mw-content-text .mw-references-wrap
    FOR    ${element}    IN    @{references_elements}
        ${ref_text}=    Get Text    ${element}
        ${content}=    Replace String    ${content}    ${ref_text}    ${EMPTY}
    END
    [Return]    ${content}

Extract References Hyperlinks
    [Documentation]    Extracts all hyperlinks from the References section.
    Scroll Element Into View    css=#References
    @{links}=    Get Webelements    css=ol.references li[id^='cite_note'] a.external.text
    @{hrefs}=    Create List
    FOR    ${link}    IN    @{links}
        ${href}=    Get Element Attribute    ${link}    href
        Append To List    ${hrefs}    ${href}
    END
    [Return]    ${hrefs}


Write Text To File
    [Documentation]    Writes the extracted text to a file.
    [Arguments]    ${text}
    Create File    ${TEXT_FILE_NAME}    ${text}

Write Links To File
    [Documentation]    Writes the extracted links to a file.
    [Arguments]    @{links}
    Create File    ${LINKS_FILE_NAME}    ${EMPTY}
    FOR    ${link}    IN    @{links}
        Append To File    ${LINKS_FILE_NAME}    ${link}\n
    END

*** Test Cases ***
Scrape Wikipedia Page
    ${text}=    Extract Text
    Log To Console    ${text}
    Write Text To File    ${text}
    
    @{hyperlinks}=    Extract References Hyperlinks
    Write Links To File    @{hyperlinks}

