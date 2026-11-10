# RaceDay

## Student Details

- **Name:** Lesego Ramoba
- **Student Number:** ST10490519
- **Project:** RaceDay Event Management System
- **Technologies:** C#, ASP.NET Core (API & MVC), SQL Server, Entity Framework Core, Azure Blob Storage, Docker, GitHub Actions

---

## Project Overview

RaceDay is a web-based event management system designed for running, walking, and cycling events in South Africa.

The system aims to simplify event management, participant registration, event enrolments, and race result tracking.

The project is developed in stages:

- **Part 1:** System Planning and Database Design
- **Part 2:** REST API Development and Testing
- **Part 3:** MVC Frontend, Authentication, Azure Blob Storage & Docker

---
**NB: PART 3 FOLDER IS INSIDE PART 2 FOLDER** 
## User Roles

The system supports two main user roles.

### Organiser
- Create, view, update, and delete events.
- Manage event categories.
- View participant enrolments.
- Record and publish race results.

### Participant
- Register and log in.
- View and update their profile.
- Browse available sporting events.
- Register for sporting events.

---

# Part 1: System Planning and Database

## Overview
Part 1 focused on the design and planning of the RaceDay system. The following components were prepared:

- Entity Relationship Diagram (ERD).
- API endpoint plan.
- SQL Server database creation script.
- Sample database records.
- Database constraints and validation.
- GitHub repository structure.

All planning documentation and database scripts are stored in the `docs` folder.

## Database Design
The Part 1 database design contains six main tables: Roles, Users, Events, Categories, Enrolments, and Results. The SQL script was tested successfully in SQL Server Management Studio and includes 8 CHECK constraints, 5 DEFAULT constraints, 7 FOREIGN KEY constraints, 6 PRIMARY KEY constraints, and 6 UNIQUE constraints.

## Part 1 Video Presentation
[Watch RaceDay Part 1 Presentation](https://youtu.be/zF8vHiiyGis)

---

# Part 2: RaceDay REST API Development

## Overview
Part 2 focused on developing a functional REST API using ASP.NET Core and SQL Server. The API manages Sporting Events, Participants, and Event Registrations using Entity Framework Core.

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

## Part 2 YouTube Demonstration
[Watch RaceDay API Part 2 Demonstration](https://youtu.be/V2Ta4LGTJIs)

---

# Part 3: MVC Frontend, Docker & Azure Integration

## Overview
Part 3 introduces the **ASP.NET Core MVC frontend** which serves as the user interface for the platform. The MVC application does not contain any direct database access; instead, it communicates entirely with the Part 2 RESTful API using `HttpClient`.

### Key Features Implemented in Part 3:
*   **Session-Based Authentication:** Users can register and log in. Session management is used to maintain the authenticated state across pages.
*   **Role-Based Navigation:** The navigation bar dynamically changes based on the user's login status and role.
*   **API Consumption:** The MVC application consumes the Part 2 API for all data operations (Events, Auth).
*   **RaceDay UI:** A custom, energetic interface using Bootstrap, featuring the RaceDay colour palette (Red/Dark Grey) and responsive event cards.
*   **Azure Blob Architecture:** File uploads are handled by sending the file from the MVC app to the API. The API uses the `Azure.Storage.Blobs` SDK to upload it to Azure storage (simulated locally using the Azurite emulator). The MVC app never talks to Azure directly.
*   **Docker Integration:** The MVC application is fully containerized.

## Part 3 Video Presentation
[Watch RaceDay Part 3 MVC & Docker Demonstration](https://youtu.be/wmVI5z1JeWk)

---

## 🐳 Docker Setup (Run Instructions)

The MVC application has been containerized using a multi-stage Dockerfile. 
To build and run the application inside a Docker container, run the following commands from the root of the repository:

```bash
# 1. Build the Docker image
docker build -t raceday-mvc -f Part2/RaceDay.MVC/Dockerfile .

# 2. Run the container
docker run -p 8080:8080 raceday-mvc
