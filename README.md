
# RaceDay

## Student Details

- **Name:** Lesego Ramoba
- **Student Number:** ST10490519
- **Project:** RaceDay Event Management System
- **Technologies:** C#, ASP.NET Core, SQL Server, Entity Framework Core, GitHub Actions

---

## Project Overview

RaceDay is a web-based event management system designed for running, walking, and cycling events in South Africa.

The system aims to simplify event management, participant registration, event enrolments, and race result tracking.

The project is developed in stages:

- **Part 1:** System Planning and Database Design
- **Part 2:** REST API Development and Testing

---

## User Roles

The planned system supports two main user roles.

### Organiser

- Create, view, update, and delete events.
- Manage event categories.
- View participant enrolments.
- Record and publish race results.
- Manage participant finish times and positions.

### Participant

- Register and log in.
- View and update their profile.
- Browse available sporting events.
- Select event categories.
- Register for sporting events.
- View enrolments and race results.

**Note:** Role-based login and dashboards are planned features and are not yet implemented in the Part 2 API.

---

# Part 1: System Planning and Database

## Overview

Part 1 focused on the design and planning of the RaceDay system.

The following components were prepared:

- Entity Relationship Diagram (ERD).
- API endpoint plan.
- SQL Server database creation script.
- Sample database records.
- Database constraints and validation.
- GitHub repository structure.
- GitHub Actions validation workflow.

All planning documentation and database scripts are stored in the `docs` folder.

## Database Design

The Part 1 database design contains six main tables:

| Table | Sample Records |
|-------|----------------|
| Roles | 2 |
| Users | 4 |
| Events | 3 |
| Categories | 6 |
| Enrolments | 6 |
| Results | 2 |

The SQL script was tested successfully in SQL Server Management Studio.

### Database Constraints

The database validation script checks:

- 8 CHECK constraints
- 5 DEFAULT constraints
- 7 FOREIGN KEY constraints
- 6 PRIMARY KEY constraints
- 6 UNIQUE constraints

## Part 1 Setup Instructions

1. Clone or download the GitHub repository.
2. Install SQL Server 2016 or later.
3. Open SQL Server Management Studio (SSMS).
4. Connect to your SQL Server instance.
5. Open `docs/RaceDay_Database.sql`.
6. Execute the complete SQL script.
7. Check the Results and Messages tabs.
8. Run `docs/Verify_Constraints.sql`.

The Part 1 script creates the RaceDay database if it does not already exist.

It is designed to avoid overwriting existing database tables.

Sample user passwords are not available for login because the generated passwords were discarded after hashing.

## Part 1 CI/CD Validation

GitHub Actions was configured to validate the required Part 1 repository files.

Workflow:

`.github/workflows/part1-validation.yml`

The workflow verifies that the required planning documents and SQL files exist.

### Part 1 CI/CD Evidence

[View Successful Part 1 GitHub Actions Validation](https://github.com/lesegoRamoba/RaceDay/blob/main/docs/CI_Green_Build.png)

## Part 1 Video Presentation

[Watch RaceDay Part 1 Presentation](https://youtu.be/zF8vHiiyGis)

---

# Part 2: RaceDay REST API Development

## Overview

Part 2 focused on developing a functional REST API using ASP.NET Core and SQL Server.

The API manages:

1. Sporting Events
2. Participants
3. Event Registrations

The application uses Entity Framework Core to communicate with the SQL Server database.

## Technologies Used

- C#
- ASP.NET Core Web API
- .NET 8
- SQL Server LocalDB
- Entity Framework Core 8
- Swagger / OpenAPI
- Visual Studio
- Git and GitHub
- GitHub Actions CI/CD

## Project Structure

The Part 2 project is located at:

`Part2/RaceDay.API`

Main project components:

### Models

- `Event.cs`
- `Participant.cs`
- `Registration.cs`

### Controllers

- `EventsController.cs`
- `ParticipantsController.cs`
- `RegistrationsController.cs`

### Data

- `RaceDayDbContext.cs`

### Database

- Entity Framework Core Migrations
- SQL Server LocalDB
- RaceDayDB

## Implemented API Features

### Events API

Supports:

- Creating events
- Retrieving all events
- Retrieving an event by ID
- Updating events
- Deleting events

### Participants API

Supports:

- Creating participants
- Retrieving participant information
- Updating participant records
- Deleting participants

### Registrations API

Supports:

- Creating registrations
- Retrieving registrations
- Updating registration records
- Deleting registrations

## REST API Endpoints

| HTTP Method | Endpoint | Description |
|-------------|----------|-------------|
| GET | /api/Events | Retrieve all events |
| GET | /api/Events/{id} | Retrieve an event by ID |
| POST | /api/Events | Create an event |
| PUT | /api/Events/{id} | Update an event |
| DELETE | /api/Events/{id} | Delete an event |
| GET | /api/Participants | Retrieve participants |
| POST | /api/Participants | Create a participant |
| GET | /api/Registrations | Retrieve registrations |
| POST | /api/Registrations | Create a registration |

Additional CRUD endpoints are provided by the generated controllers.

## Part 2 Setup Instructions

1. Clone or download the GitHub repository.
2. Open `Part2/RaceDay.sln` using Visual Studio.
3. Ensure the .NET 8 SDK is installed.
4. Ensure SQL Server LocalDB is installed.
5. Restore all NuGet packages.
6. Open `appsettings.json`.
7. Configure the `DefaultConnection` connection string.
8. Open the NuGet Package Manager Console.
9. Select `RaceDay.API` as the default project.
10. Execute the following command:

```powershell
Update-Database
```

11. Wait for the migrations to complete.
12. Press F5 to start the application.
13. Open Swagger using `/swagger`.
14. Test the available API endpoints.

## Database Integration

The API connects to SQL Server using Entity Framework Core.

The development database is named:

`RaceDayDB`

The database includes the following tables:

- Events
- Participants
- Registrations
- __EFMigrationsHistory

Entity Framework Core migrations were used to generate the database structure.

## API Testing

API testing was performed using Swagger.

### Successful Tests

| Test | Response |
|------|----------|
| Retrieve Events | 200 OK |
| Create Event | 201 Created |
| Retrieve Participants | 200 OK |
| Create Participant | 201 Created |
| Retrieve Registrations | 200 OK |
| Update Event | 204 No Content |
| Delete Event | 204 No Content |
| Request Nonexistent Event | 404 Not Found |

These tests demonstrate the basic CRUD functionality of the API.

## Part 2 Testing Evidence

The following screenshots document the API testing process:

### Screenshot 1: Swagger API Overview

Shows the Events, Participants, and Registrations endpoints.

### Screenshot 2: GET Participants

Shows a successful 200 OK response when retrieving participant records.

### Screenshot 3: GET Registrations

Shows successful retrieval of event registration records.

### Screenshot 4: GitHub Actions Green Build

Shows successful execution of the Part 2 CI/CD build workflow.

The screenshots are intended to be stored in the repository's `docs` folder.

## GitHub Actions CI/CD

A GitHub Actions workflow was created for Part 2.

Workflow file:

`.github/workflows/part2-build.yml`

The workflow automatically:

1. Checks out the repository.
2. Installs the .NET 8 SDK.
3. Restores project dependencies.
4. Builds the RaceDay API in Release configuration.

The workflow successfully completed with a green build status.

[View GitHub Actions](https://github.com/lesegoRamoba/RaceDay/actions)

## Part 2 YouTube Demonstration

The following video demonstrates the RaceDay API implementation, Visual Studio project structure, database integration, Swagger testing, and GitHub Actions workflow.

**RaceDay Part 2 Video Presentation:**

[Watch RaceDay API Part 2 Demonstration](https://youtu.be/V2Ta4LGTJIs)

Direct YouTube Link:

https://youtu.be/V2Ta4LGTJIs

## Development Status

### Completed

- ASP.NET Core Web API project setup
- Event, Participant and Registration models
- SQL Server database integration
- Entity Framework Core migrations
- CRUD API controllers
- Swagger API testing
- Error response testing
- GitHub repository integration
- Successful Part 2 CI/CD build
- Part 2 YouTube demonstration

### Future Improvements

- User authentication and authorisation
- Organiser and participant dashboards
- Event category management
- Race results management
- Stronger data validation
- Improved relationships between events and registrations
- Additional automated API tests

---

## GitHub Repository

The complete RaceDay project is available at:

https://github.com/lesegoRamoba/RaceDay

## Conclusion

RaceDay demonstrates the development of a database-driven REST API using C#, ASP.NET Core, Entity Framework Core and SQL Server.

Part 1 established the system design and database planning.

Part 2 implemented working API controllers, database operations, Swagger testing and continuous integration using GitHub Actions.

The project provides a foundation for future development of a complete sporting event management system.

---

**Developed by:** Lesego Ramoba

**Student Number:** ST10490519

**Project:** RaceDay
