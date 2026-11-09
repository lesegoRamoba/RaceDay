# 🏃‍♂️ RaceDay - Part 3 (MVC Frontend & Docker)

**Student Number:** ST10490519  
**Module:** PROG6212  
**Repository:** [https://github.com/lesegoRamoba/RaceDay](https://github.com/lesegoRamoba/RaceDay)

## 🎥 Video Presentation
[INSERT YOUR UNLISTED YOUTUBE LINK HERE]

---

## 📖 Project Overview
RaceDay is a comprehensive event-management platform for running, walking, and cycling events. 
Part 3 introduces the **ASP.NET Core MVC frontend** which serves as the user interface for the platform. The MVC application does not contain any direct database access; instead, it communicates entirely with the **Part 2 RESTful API** using `HttpClient`.

### Key Features Implemented in Part 3:
*   **MVC Architecture:** A clean separation of concerns with Models, Views, and Controllers.
*   **Session-Based Authentication:** Users can register and log in. Session management is used to maintain the authenticated state across pages, and the navigation bar dynamically changes based on the user's role.
*   **API Consumption:** The MVC application consumes the Part 2 API for all data operations (Events, Participants, Auth).
*   **RaceDay Branding:** A custom, energetic UI using Bootstrap, featuring the RaceDay colour palette (Red/Dark Grey), responsive event cards, and a dynamic navigation bar.
*   **Docker Integration:** The MVC application is fully containerized.

---

## 🐳 Docker Setup (Run Instructions)

The MVC application has been containerized using a multi-stage Dockerfile. 
To build and run the application inside a Docker container, run the following commands from the root of the repository:

```bash
# 1. Build the Docker image
docker build -f Part2/RaceDay.MVC/Dockerfile -t raceday-mvc .

# 2. Run the container
docker run -p 8080:8080 raceday-mvc
The MVC application will be available at: http://localhost:8080

(Note: The API must be running locally on port 7158 for the MVC app to fetch data).

⚙️ GitHub Actions (CI/CD)
The repository includes a GitHub Actions workflow (.github/workflows/part2-build.yml).
This workflow is triggered on every push to the main branch. It automatically restores and builds both the Part 2 API and the Part 3 MVC project to ensure code integrity and a green build status.

☁️ Azure Blob Storage Integration
Note on Azure implementation:
The architecture is designed so that the MVC application handles file uploads by sending them to the API via MultipartFormDataContent. The API then interfaces with Azure Blob Storage. Due to time constraints, the UI for file uploading is scaffolded, and the API endpoints are prepared for the Azure SDK integration.

💻 How to Run Locally (Visual Studio 2022)
Clone the repository and open Part2/RaceDay.sln in Visual Studio 2022.

Ensure the RaceDay.API project is set to run on https://localhost:7158.

Right-click the Solution -> Configure Startup Projects -> Select Multiple startup projects.

Set both RaceDay.API and RaceDay.MVC to Start.

Press F5.

Swagger UI will open for the API.

The MVC application will open in a separate browser window.
