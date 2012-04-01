Feature: Records
  As a Ŝelr user
  I would like to browse and publish records
  In order to know something new or impress my friends

  @javascript
  Scenario: browsing records
    Given I signed in
    And there are 3 records in db
    When I visit "/records" page
    Then I should see some records
