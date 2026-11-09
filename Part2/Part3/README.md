# 🏃‍♂️ RaceDay - Part 3 (MVC Frontend & Docker)

**Student Number:** ST10490519  
**Module:** PROG6212  
**Repository:** [https://github.com/lesegoRamoba/RaceDay](https://github.com/lesegoRamoba/RaceDay)

## 🎥 Video Presentation
https://youtu.be/wmVI5z1JeWk

PART 2 CONTAINTS PART 3 INFORMATION

---

## 📖 Project Overview
RaceDay is a comprehensive event-management platform for running, walking, and cycling events. 
Part 3 introduces the **ASP.NET Core MVC frontend** which serves as the user interface for the platform. The MVC application does not contain any direct database access; instead, it communicates entirely with the **Part 2 RESTful API** using `HttpClient`.

### Key Features Implemented:
*   **MVC Architecture:** Clean separation of concerns.
*   **Session-Based Authentication:** Users can register and log in. Session management maintains the authenticated state, and the navigation bar dynamically changes based on the user's login status.
*   **API Consumption:** The MVC app consumes the API for all data operations (Events, Auth, Blob).
*   **Azure Blob Architecture:** File uploads are handled by sending the file from the MVC app to the API. The API uses the `Azure.Storage.Blobs` SDK to upload it to Azure storage.
*   **Docker Integration:** The MVC application is fully containerized.

---

## 🐳 Docker Setup (Run Instructions)

The MVC application has been containerized using a multi-stage Dockerfile. 
To build and run the application inside a Docker container, run the following commands from the root of the repository:

```bash
# 1. Build the Docker image
docker build -t raceday-mvc -f Part2/RaceDay.MVC/Dockerfile .

# 2. Run the container
docker run -p 8080:8080 raceday-mvc

The MVC application will be available at: http://localhost:8080
(Note: The API must be running locally on port 7158 for the MVC app to fetch data).

⚙️ GitHub Actions (CI/CD)
The repository includes a GitHub Actions workflow (.github/workflows/part2-build.yml). It automatically restores and builds both the Part 2 API and the Part 3 MVC project on every push.

https://green-build.png/

☁️ Azure Blob Storage Integration
To fulfill the rubric requirement (MVC must not talk directly to Azure), the architecture is implemented as follows:

The Organiser selects an image on the MVC Dashboard.

The MVC app sends the file as MultipartFormDataContent to the API's BlobController.

The API uses the Azure.Storage.Blobs SDK and a connection string to upload the file to an Azure Blob container.

(Note: For local development and testing, the official Microsoft Azurite emulator was used via Docker to simulate the Azure environment).



💻 How to Run Locally (Visual Studio 2022)
Clone the repository and open Part2/RaceDay.sln in Visual Studio 2022.

Ensure the RaceDay.API project is set to run on https://localhost:7158.

Right-click the Solution -> Configure Startup Projects -> Select Multiple startup projects.

Set both RaceDay.API and RaceDay.MVC to Start.

Press F5.

Swagger UI will open for the API.

The MVC application will open in a separate browser window.
