# RaceDay — API Endpoint Plan

**Student:** Lesego Ramoba · **Student number:** ST10490519  
**Submission:** Part 1, Section B · **Status:** Draft plan for Part 2.

This document sets out the planned API endpoints for RaceDay. It covers user accounts, profiles, events, categories, enrolments and race results, as well as the image uploads needed in Part 3. The endpoints are still at the planning stage and have not been built or tested.

## 1\. General rules and access

* All routes start with `/api`. Resource IDs are positive integers. JSON uses camelCase; date-only values use `YYYY-MM-DD`, and timestamps use ISO 8601 UTC. `EventDate` is the scheduled start of the event in UTC.
* `None (public)` means no login is required. `Any authenticated` means either supported role. `Organiser (owner)` means an Organiser who created the referenced event. `Participant (self)` means the signed-in participant. The API checks both role and ownership on every applicable request.
* Use **server-side session authentication**, as required by the assessment. After successful login, renew the session identifier and store the user ID and role server-side. Use a secure, HttpOnly session cookie; return no bearer token. Logout invalidates the session. Expired or missing sessions receive `401`.
* For cookie-authenticated requests, validate an anti-forgery token on POST, PUT and DELETE, including login and registration. Obtain it from the CSRF endpoint, send it as `X-CSRF-TOKEN`, and refresh it after login/logout. Invalid or missing tokens return `400`. Swagger UI must support this header and session cookies so all endpoints remain browser-testable.
* The MVC application uses the API to read and update data and upload files. Each signed-in user must have a separate API session and cookie container. The API handles access to the database and Azure.
* Get `OrganiserID` and `ParticipantID` from the signed-in session, rather than accepting them in the request. Profile updates cannot change `RoleID`, password hashes or image URLs. Use explicit request and response DTOs so protected fields cannot be over-posted.
* Responses must never expose password hashes, session identifiers or raw database errors. List endpoints return `200` with an empty list when there are no matches.
* All protected endpoints additionally return `401` for a missing/expired session. Role-restricted endpoints return `403` for a wrong role; owner/self endpoints return `403` for another user's resource. Unknown resource IDs return `404`. These rules apply to the relevant endpoints in the tables below.
* Invalid JSON, out-of-range IDs, field lengths, dates, enum values or business validation inputs return `400` with field-level errors. Conflict with existing state returns `409`. A successful create returns `201` with the resource and, where a corresponding GET exists, a `Location` header. A `204` response has no body.
* The API will use strongly-typed DTOs to prevent over-posting of sensitive fields.

## 2\. Authentication and session endpoints — Part 2

|HTTP Method|Route|Description|Role Required|Request Body (if any)|Expected Response|
|-|-|-|-|-|-|
|GET|`/api/auth/csrf`|Get an anti-forgery token for the current browser session.|None (public)|None|`200` `{ csrfToken }` and any required cookie.|
|POST|`/api/auth/register`|Create an account, hash its password and assign the selected supported role. Does not automatically log in.|None (public)|`RegisterRequest`|`201` safe `UserProfile`; `400` invalid fields/role/password; `409` email already registered.|
|POST|`/api/auth/login`|Check the email and password and start a new server-side session.|None (public)|`{ "email": "participant@example.com", "password": "user-supplied password" }`|`200` safe `UserProfile` and session cookie; `400` missing/invalid fields; `401` invalid credentials using a generic message.|
|GET|`/api/auth/session`|Return the signed-in user's ID and role so clients can restore navigation state.|Any authenticated|None|`200` `{ userId, roleName }`; `401` no valid session.|
|POST|`/api/auth/logout`|End the current session and clear its cookie.|Any authenticated|None|`204` session ended; `401` no valid session.|

## 3\. Own profile endpoints — Part 2

|HTTP Method|Route|Description|Role Required|Request Body (if any)|Expected Response|
|-|-|-|-|-|-|
|GET|`/api/users/me`|Get the signed-in user's profile without including their password or password hash.|Any authenticated|None|`200` `UserProfile`; `401` no valid session.|
|PUT|`/api/users/me`|Update the signed-in user's personal details, keeping their role unchanged.|Any authenticated|`ProfileUpdateRequest`|`200` updated `UserProfile`; `400` invalid details; `409` email belongs to another account or birth-date change invalidates an active age-category entry.|

## 4\. Event endpoints — Part 2

Organisers, Participants and visitors can browse events. Only the Organiser who created an event can change it.

|HTTP Method|Route|Description|Role Required|Request Body (if any)|Expected Response|
|-|-|-|-|-|-|
|GET|`/api/events`|Browse events, supporting the Participant home page and filtering. Optional query: `upcomingOnly=true`, `eventType`, `location`, `from`, `to`, `page=1`, `pageSize=20`.|None (public)|None|`200` `{ items: EventSummary\[], page, pageSize, totalCount }`; `400` invalid filters or pagination.|
|GET|`/api/events/{eventId}`|View full event details, its banner URL and available categories.|None (public)|None|`200` `EventDetail`; `404` event missing.|
|POST|`/api/events`|Create an event owned by the logged-in Organiser.|Organiser|`EventRequest`|`201` `EventDetail`; `400` invalid fields, nonpositive distance or nonfuture start.|
|PUT|`/api/events/{eventId}`|Update an event while keeping its enrolments and results consistent.|Organiser (owner)|`EventRequest`|`200` updated `EventDetail`; `400` invalid fields; `404` missing; `409` attempted change to date, type or distance after enrolments exist, or event has already started.|
|DELETE|`/api/events/{eventId}`|Delete an owned event that has no enrolments; remove its categories in the same database transaction.|Organiser (owner)|None|`204` deleted; `404` missing; `409` enrolments exist, including cancelled entries.|
|GET|`/api/organiser/events`|List the current Organiser's own events with entry totals for event management.|Organiser|None|`200` array of owned event summaries with totalEnrolments and activeEnrolments; `401`/`403` access failure.|
|GET|`/api/organiser/dashboard`|Return totals and upcoming dates for the Organiser dashboard.|Organiser|None|`200` `{ totalEvents, totalEnrolments, events: \[{ eventId, eventName, eventDate, enrolmentCount }] }`; `401`/`403` access failure.|

## 5\. Event category endpoints — Part 2

|HTTP Method|Route|Description|Role Required|Request Body (if any)|Expected Response|
|-|-|-|-|-|-|
|GET|`/api/events/{eventId}/categories`|List all age or distance categories for an event.|None (public)|None|`200` `Category\[]`; `404` event missing.|
|GET|`/api/events/{eventId}/categories/{categoryId}`|Get one category, including its age limits or distance.|None (public)|None|`200` `Category`; `404` event/category missing or category belongs to another event.|
|POST|`/api/events/{eventId}/categories`|Add a category to an owned future event.|Organiser (owner)|`CategoryRequest`|`201` `Category`; `400` invalid bounds/type/distance; `404` event missing; `409` duplicate category name in the event or event has started.|
|PUT|`/api/events/{eventId}/categories/{categoryId}`|Update a category belonging to an owned future event.|Organiser (owner)|`CategoryRequest`|`200` updated `Category`; `400` invalid fields; `404` event/category mismatch; `409` duplicate name, existing enrolments in this category or event has started.|
|DELETE|`/api/events/{eventId}/categories/{categoryId}`|Delete a category with no enrolments from an owned future event.|Organiser (owner)|None|`204` deleted; `404` event/category mismatch; `409` linked enrolments or event has started.|

## 6\. Enrolment endpoints — Part 2

|HTTP Method|Route|Description|Role Required|Request Body (if any)|Expected Response|
|-|-|-|-|-|-|
|POST|`/api/events/{eventId}/enrolments`|Enter a future event by selecting one category; record the session's participant and default status Confirmed.|Participant (self)|`{ "categoryId": 1 }`|`201` `EnrolmentDetail`; `400` age ineligible or malformed input; `404` event/category missing or mismatched; `409` existing entry or event has started.|
|GET|`/api/users/me/enrolments`|View all of the Participant's own entries and their statuses.|Participant (self)|None|`200` `EnrolmentDetail\[]`; `401`/`403` access failure.|
|GET|`/api/users/me/enrolments/{enrolmentId}`|View one entry owned by the signed-in Participant.|Participant (self)|None|`200` `EnrolmentDetail`; `404` missing; `403` another Participant's entry.|
|PUT|`/api/users/me/enrolments/{enrolmentId}/cancellation`|Cancel the Participant's own entry before the event and keep the record in their history.|Participant (self)|None|`200` cancelled `EnrolmentDetail` (also if already cancelled); `404` missing; `409` event has started or a result is recorded.|
|GET|`/api/events/{eventId}/enrolments`|List entries, selected categories, participant names and statuses for an owned event.|Organiser (owner)|None|`200` `OrganiserEnrolmentDetail\[]`; `404` event missing; `403` wrong owner.|
|PUT|`/api/events/{eventId}/enrolments/{enrolmentId}/status`|Manage an entry's status before the event.|Organiser (owner)|`{ "enrolmentStatus": "Confirmed" }`|`200` updated `EnrolmentDetail`; `400` unsupported status; `404` entry/event mismatch; `409` forbidden transition, event started or a result exists.|

## 7\. Race result endpoints — Part 2

|HTTP Method|Route|Description|Role Required|Request Body (if any)|Expected Response|
|-|-|-|-|-|-|
|POST|`/api/events/{eventId}/results`|Record a draft result for a confirmed participant entry after the race has finished.|Organiser (owner)|`ResultCreateRequest`|`201` `ResultDetail`; `400` invalid time/position; `404` event/entry mismatch; `409` result already exists, entry is not Confirmed, race start is in the future, or finish time extends beyond the current time.|
|GET|`/api/events/{eventId}/results`|View all draft and published results for an owned event.|Organiser (owner)|None|`200` `ResultDetail\[]`; `404` event missing.|
|GET|`/api/events/{eventId}/results/{resultId}`|Retrieve one result for an owned event.|Organiser (owner)|None|`200` `ResultDetail`; `404` result/event mismatch.|
|PUT|`/api/events/{eventId}/results/{resultId}`|Correct a result; reset publication so corrections are reviewed before release.|Organiser (owner)|`ResultUpdateRequest`|`200` updated `ResultDetail` with isPublished=false; `400` invalid time/position; `404` result/event mismatch; `409` entry not Confirmed or finish time incompatible with elapsed event time.|
|PUT|`/api/events/{eventId}/results/{resultId}/publication`|Publish or unpublish a recorded result after the Organiser confirms the race has concluded.|Organiser (owner)|`{ "isPublished": true }`|`200` updated `ResultDetail`; `400` invalid body; `404` result/event mismatch; `409` result/entry is not eligible for publication or event has not yet started.|
|DELETE|`/api/events/{eventId}/results/{resultId}`|Remove an incorrect draft result; a published result must first be unpublished.|Organiser (owner)|None|`204` deleted; `404` result/event mismatch; `409` result is still published.|
|GET|`/api/users/me/results`|Show the Participant's published personal race history, with optional `eventId` filter.|Participant (self)|None|`200` `PersonalResult\[]` sorted by event date descending; `400` invalid filter; `401`/`403` access failure.|

## 8\. Image endpoints — planned now, implemented in Part 3

The MVC client sends images to the API. The API checks each file, uploads it to Azure Blob Storage and saves the image URL in the field shown in the ERD. Users cannot supply their own destination URL.

|HTTP Method|Route|Description|Role Required|Request Body (if any)|Expected Response|
|-|-|-|-|-|-|
|POST|`/api/events/{eventId}/banner`|Upload or replace the owned event's banner and update Events.BannerImageUrl.|Organiser (owner)|`multipart/form-data`: required field `file` (PNG or JPEG, maximum 5 MiB).|`200` `{ bannerImageUrl }`; `400` corrupt image; `404` missing event; `413` too large; `415` unsupported type; `503` storage unavailable.|
|DELETE|`/api/events/{eventId}/banner`|Remove the banner reference and arrange removal of its stored blob.|Organiser (owner)|None|`204` removed (also if already absent); `404` event missing; `503` storage unavailable.|
|POST|`/api/users/me/profile-picture`|Upload or replace the signed-in user's profile picture and update Users.ProfilePictureUrl.|Any authenticated|`multipart/form-data`: required field `file` (PNG or JPEG, maximum 5 MiB).|`200` `{ profilePictureUrl }`; `400` corrupt image; `413` too large; `415` unsupported type; `503` storage unavailable.|
|DELETE|`/api/users/me/profile-picture`|Remove the signed-in user's profile-picture reference and arrange removal of its stored blob.|Any authenticated|None|`204` removed (also if already absent); `503` storage unavailable.|

## 9\. Request body definitions

The examples below show the fields accepted by each request body in the tables. Optional fields can be null. Required text fields cannot be blank, and text lengths must stay within the limits in the ERD.

### RegisterRequest

```json
{
  "firstName": "Lerato",
  "lastName": "Mokoena",
  "email": "lerato@example.com",
  "password": "a user-chosen password",
  "dateOfBirth": "2000-05-14",
  "phoneNumber": null,
  "roleName": "Participant"
}
```

All except phoneNumber are required. RoleName is exactly Organiser or Participant. Users can choose either supported role when registering. The API checks the role name and finds its matching Roles.RoleID. It does not accept a RoleID supplied by the user. Use a documented password policy (proposed: 12–128 characters), a password-hashing library with a unique salt, and normalised unique emails. Never include passwords in seed data as plaintext or in responses/logs.

### ProfileUpdateRequest

```json
{
  "firstName": "Lerato",
  "lastName": "Mokoena",
  "email": "lerato@example.com",
  "dateOfBirth": "2000-05-14",
  "phoneNumber": "+27820000000"
}
```

All except phoneNumber are required. Validate date of birth against today; age-category eligibility is based on age on the event date. Do not allow a profile birth-date change to invalidate an active future entry.

### EventRequest

```json
{
  "eventName": "Soshanguve Community Run",
  "description": "A community road-running event.",
  "eventDate": "2027-05-15T05:00:00Z",
  "location": "Soshanguve, Pretoria, South Africa",
  "distanceKm": 10.00,
  "eventType": "Run"
}
```

All fields are required. Distance is positive with at most two decimal places and must fit DECIMAL(6,2). EventType is Run, Walk or Cycle. Images use the separate upload route. Event distance is the headline distance; a distance category may specify its own race distance.

### CategoryRequest

Age category example:

```json
{
  "categoryName": "Under 20",
  "categoryType": "Age",
  "minAge": null,
  "maxAge": 19,
  "distanceKm": null
}
```

Distance category example:

```json
{
  "categoryName": "10 km",
  "categoryType": "Distance",
  "minAge": null,
  "maxAge": null,
  "distanceKm": 10.00
}
```

CategoryName and categoryType are required. For Age, at least one bound is required; bounds are inclusive nonnegative integers, minAge cannot exceed maxAge, and distanceKm is null. For Distance, distanceKm is positive and both age bounds are null. Names are unique within an event.

### ResultCreateRequest / ResultUpdateRequest

```json
{
  "enrolmentId": 1,
  "finishTimeSeconds": 3725,
  "finishingPosition": 12
}
```

The create request requires all three fields. The update request contains **only finishTimeSeconds and finishingPosition**; the associated enrolment cannot be changed. Both values are integers: finishTimeSeconds >= 0 and finishingPosition > 0. Times in seconds permit events lasting longer than 24 hours. The API sets RecordedAt and defaults IsPublished to false.

## 10\. Response definitions

|Response|Returned fields|
|-|-|
|UserProfile|userId, roleName, firstName, lastName, email, dateOfBirth, phoneNumber, profilePictureUrl, createdAt. Never password or passwordHash.|
|EventSummary|eventId, eventName, eventDate, location, distanceKm, eventType, bannerImageUrl.|
|EventDetail|EventSummary fields plus organiserId, description and categories. Do not expose the Organiser's private contact/profile fields.|
|Category|categoryId, eventId, categoryName, categoryType, minAge, maxAge, distanceKm.|
|EnrolmentDetail|enrolmentId, eventId, eventName, eventDate, categoryId, categoryName, enrolmentStatus, enrolledAt.|
|OrganiserEnrolmentDetail|EnrolmentDetail fields plus participantId, firstName and lastName. Do not expose passwords or unnecessary private profile fields.|
|ResultDetail|resultId, enrolmentId, eventId, categoryId, participantId, participantName, finishTimeSeconds, finishingPosition, isPublished, recordedAt.|
|PersonalResult|resultId, eventId, eventName, eventDate, categoryId, categoryName, finishTimeSeconds, formattedFinishTime, finishingPosition, totalFinishers.|
|Error|Problem-style JSON containing status, title and safe detail; field validation also includes an errors dictionary.|

## 11\. Implementation rules

1. **Role and ownership:** Only an Organiser may own events. Only Participants may enrol. Foreign keys establish valid users; the API enforces their roles and current session ownership.
2. **Category/event integrity:** Enrolments stores EventID and CategoryID. Use a composite foreign key to Categories(EventID, CategoryID), backed by its composite unique key. Also retain the direct EventID foreign key to Events. Reject a category from another event.
3. **One entry per event:** UNIQUE(ParticipantID, EventID) prevents duplicate entries, including concurrent requests. Convert uniqueness violations to `409`. A cancelled entry is retained; an Organiser may reactivate it before the event after checking eligibility.
4. **Statuses:** Supported values are Pending, Confirmed and Cancelled. New entries default to Confirmed. Before the event, Organisers may move Pending to Confirmed/Cancelled, Confirmed to Pending/Cancelled, and Cancelled to Pending/Confirmed. Repeating the current status is a no-op. Reactivation rechecks age eligibility. Entries with results cannot change status.
5. **Results:** Results.EnrolmentID is unique. The Organiser confirms the race has concluded before recording/publishing results; the schema has no event-end field, so the API can verify scheduled start and elapsed finish time, but cannot independently prove race conclusion. A participant sees only their own published results.
6. **Position scope:** FinishingPosition is the Organiser-assigned overall position within the selected category. Tied positions are permitted. totalFinishers is calculated from published results for that same event/category, not from all enrolled participants. During partial publication the total is provisional; the MVC interface should label it accordingly.
7. **Deletion:** Database foreign keys use NO ACTION. Event deletion removes unreferenced categories transactionally before deleting the event. Any linked enrolment blocks event/category deletion, preserving history. Result deletion requires unpublication first.
8. **Defaults:** All primary keys use IDENTITY(1,1). CreatedAt, EnrolledAt and RecordedAt default to SYSUTCDATETIME(); EnrolmentStatus defaults to Confirmed and IsPublished to 0. Requiredness and lengths match the ERD.
9. **Pagination:** For GET /api/events, page >= 1 and pageSize is 1–100. Sort by eventDate then eventId for stable results. upcomingOnly defaults to true; false includes past events for historical browsing. Optional from/to filters are inclusive UTC date boundaries and must be ordered correctly.
10. **Delivery scope:** Core rows in sections 2–7 are planned for Part 2. Azure image rows are explicitly planned for Part 3. The background mentions live weather and route information but supplies no detailed assessed endpoint contract; confirm with the lecturer whether an external provider integration is expected before adding those operations. This point still needs clarification.
11. **Swagger and tests:** Describe all requests, responses, roles and failures in Swagger. Include successful/failed registration and login, real session handling, unauthenticated access, wrong-role/ownership access, event management, category mismatches, duplicate enrolment and age checks. All required tests must pass locally and in GitHub Actions. Testing will take place during implementation; no tests have been run for this Part 1 plan.

