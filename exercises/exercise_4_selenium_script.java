// =============================================================================
// EXERCISE 4: Selenium WebDriver Refactor — Login Automation
// Time: 20 minutes  |  Points: 20  |  Type: Code (Java + Selenium)
// =============================================================================
//
// SCENARIO:
// This Selenium test "works on my machine" but flakes constantly in CI. It is
// also unmaintainable. Refactor it into a clean POM-based design with
// explicit waits and proper assertions.
//
// TASKS:
// 1. [All Levels] List every anti-pattern you see (Thread.sleep, hard-coded
//    XPaths, no waits, magic strings, no assertions, etc.) in a top comment.
//    Aim for at least 7.
// 2. [All Levels] Refactor into Page Object Model:
//      - LoginPage class with method 'public DashboardPage loginAs(String email, String password)'
//      - DashboardPage class with method 'public boolean isUserGreetingVisible()'
//      - A LoginTest class that calls them
// 3. [Mid+] Replace every Thread.sleep with appropriate WebDriverWait /
//    ExpectedConditions.
// 4. [Mid+] Parameterize the test with TestNG @DataProvider or JUnit5
//    @ParameterizedTest so it runs once with valid creds and once with invalid.
// 5. [Mid+] Add a real assertion that catches the regression where the dashboard
//    loads but the user's name is missing from the greeting.
// 6. [Senior] Move the base URL and credentials into a config file / env var
//    (do NOT commit real credentials). Stub how you'd read them.
// 7. [Senior] Add a JUnit5 @AfterEach (or TestNG @AfterMethod) that captures a
//    screenshot on failure. Stub the helper if needed.
//
// RULES:
// - Java 11+, Selenium 4.x, JUnit 5 OR TestNG — your choice
// - You may split this into multiple files if you note it in a comment
// - No need to actually compile or run — we evaluate the code as written
// =============================================================================

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.chrome.ChromeDriver;

public class LoginTest {

    public static void main(String[] args) throws Exception {
        // ANTI-PATTERN: no driver config (headless? window size? implicit waits?)
        WebDriver driver = new ChromeDriver();

        // ANTI-PATTERN: hard-coded URL
        driver.get("https://admin.example.com/login");

        // ANTI-PATTERN: Thread.sleep waiting for page load
        Thread.sleep(3000);

        // ANTI-PATTERN: brittle absolute XPath locators
        WebElement emailField = driver.findElement(
            By.xpath("/html/body/div[1]/div[2]/form/div[1]/input"));
        WebElement passwordField = driver.findElement(
            By.xpath("/html/body/div[1]/div[2]/form/div[2]/input"));
        WebElement loginBtn = driver.findElement(
            By.xpath("/html/body/div[1]/div[2]/form/button"));

        // ANTI-PATTERN: credentials hard-coded in source
        emailField.sendKeys("qa-admin@example.com");
        passwordField.sendKeys("SuperSecret123!");
        loginBtn.click();

        // ANTI-PATTERN: arbitrary sleep instead of waiting for the next page
        Thread.sleep(5000);

        // ANTI-PATTERN: no assertion — just prints. The test will "pass"
        // even if the dashboard 500-errored.
        WebElement greeting = driver.findElement(By.id("user-greeting"));
        System.out.println("Greeting text was: " + greeting.getText());

        // ANTI-PATTERN: no try/finally — if anything throws above, the browser
        // process is orphaned.
        driver.quit();
    }
}

/*
=============================================================================
SUBMISSION FORMAT
=============================================================================

Rewrite this file in place. You may also add additional files for
LoginPage.java, DashboardPage.java, BasePage.java, etc. — list them all in
a top-of-file comment.

At the top of LoginTest.java, replace the existing code with:

  // ANTI-PATTERNS FOUND IN THE ORIGINAL SCRIPT:
  //  1. ...
  //  2. ...
  //  ...
  //
  // FILES IN THIS SOLUTION:
  //  - LoginTest.java        — the test class
  //  - LoginPage.java        — POM for /login
  //  - DashboardPage.java    — POM for /dashboard
  //  - BasePage.java         — shared explicit-wait helpers
  //  - test.properties       — base_url and credential placeholders (NOT committed)

=============================================================================
EVALUATION CRITERIA
=============================================================================

| Criterion                  | Points | What We Look For
|----------------------------|--------|----------------------------------------------
| Anti-patterns identified   | 4      | At least 7 real anti-patterns, named clearly
| POM design                  | 5      | Clear separation; pages return next page; reusable
| Explicit waits              | 3      | WebDriverWait + ExpectedConditions, no Thread.sleep
| Parameterization            | 2      | DataProvider / ParameterizedTest with valid + invalid
| Greeting-regression assert  | 3      | An assertion that would catch "greeting is empty"
| Config / secrets handling   | 2      | Externalized, not hard-coded
| Screenshot on failure       | 1      | Wired into @AfterEach / @AfterMethod

=============================================================================
*/
