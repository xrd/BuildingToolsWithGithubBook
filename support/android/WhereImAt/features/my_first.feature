Feature: Login feature

  Scenario: As a valid user I can log into my app
    When I enter "myusername" into input field number 1
    And I enter "mypassword" into input field number 2
    And I press the "Login" button
    And I wait 5 seconds
    Then I see "Welcome to Ghoa"
