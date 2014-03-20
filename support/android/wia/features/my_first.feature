Feature: Login feature

  Scenario: As a valid user I can log into my app
    Then I wait for the "MainActivity" screen to appear
    Then I enter "#{ENV['gh_user'}" into input field number 1
    Then I enter "#{ENV['gh_pass'}" into input field number 2
    Then I press "Login"
    And I see "Logged into GitHub"
