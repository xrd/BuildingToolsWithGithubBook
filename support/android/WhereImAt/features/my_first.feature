Feature: Login feature

  Scenario: As a valid user I can log into my app
    When I enter "myusername"
    And I enter "mypassword"
    And I press "Login"
    Then I see "Welcome to Ghoa"
