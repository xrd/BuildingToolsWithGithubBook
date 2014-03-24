Feature: Login feature

  Scenario: As a valid user I can log into my app
    When I enter the username
    And I enter the password
    And I press "Login"
    Then I see "Logged into GitHub"
