# RaceDay

## Student Details

* Name: Lesego Ramoba
* Student Number: ST10490519

## Project Overview

RaceDay is a planned web-based event management system for

running, walking, and cycling events in South Africa.

The system will support event management, participant

enrolments, event categories, and race results.

## User Roles

### Organiser

* Create, view, update, and delete their events.
* Manage categories for their events.
* View enrolments for their events.
* Record and publish participant finish times and positions.

### Participant

* Register and log in.
* View and update their own profile.
* Browse events and available categories.
* Enter an event by selecting a category.
* View their own enrolments and results.

## Part 1: System Planning and Database

Part 1 includes:

* An Entity Relationship Diagram (ERD).
* An API endpoint plan.
* A SQL Server database creation and sample-data script.
* A GitHub Actions workflow to validate repository structure.

Planning documents and the SQL script are stored in /docs.

No application code is required for Part 1.

## Current Progress

The ERD, API endpoint plan and SQL database script are prepared.
The SQL script ran successfully in SSMS, and the constraint totals
matched the expected values. GitHub Actions file validation passed.

The video, final review and minimum 20 meaningful commits are
still outstanding.

## Setup Instructions

1. Clone or download this repository.
2. Ensure your SQL Server version is 2016 or higher.
3. Open SQL Server Management Studio (SSMS).
4. Connect to your SQL Server instance.
The instance used for testing was localhost\\SQLEXPRESS.
5. Open docs/RaceDay\_Database.sql.
6. With no text selected, press F5 to execute the entire script.
7. Check the Results and Messages tabs for successful execution.

The script creates RaceDay if it does not exist. It stops if
the database already contains tables, without overwriting them.
The SQL login needs permission to create databases and tables.

Expected sample totals:

* Roles: 2
* Users: 4
* Events: 3
* Categories: 6
* Enrolments: 6
* Results: 2

Run docs/Verify\_Constraints.sql to check the constraint totals:
8 CHECK, 5 DEFAULT, 7 FOREIGN KEY, 6 PRIMARY KEY and 6 UNIQUE.

Sample users contain password hashes. Their randomly generated
passwords were discarded, so they are not usable login accounts.

## CI Validation Evidence

The workflow in .github/workflows/part1-validation.yml checks
that the required Part 1 files exist and are not empty.
It runs on pushes and pull requests and supports manual runs.

SQL execution was checked separately in SSMS.

!\[Successful GitHub Actions validation](docs/CI\_Green\_Build.png)

## Video Presentation

An unlisted YouTube demonstration link will be added before

submission.

## AI Assistance Disclosure

ChatGPT assisted with repository setup, drafting and refining the ERD,
API endpoint plan, SQL script, verification query, GitHub Actions workflow
and README, and troubleshooting the tools used. The SQL script was run
in SSMS, and the GitHub Actions file validation completed successfully.

