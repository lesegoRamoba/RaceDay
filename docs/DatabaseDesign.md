\# RaceDay Database Design



\## Purpose

This document defines the database structure for RaceDay.

The final ERD and SQL Server script must match this design.



\## Planned Tables

1\. Roles

2\. Users

3\. Events

4\. Categories

5\. Enrolments

6\. Results



\## 1. Roles



Stores the two supported roles: Organiser and Participant.



| Column | SQL Server Type | Rules |

|---|---|---|

| RoleID | INT | Primary key, IDENTITY(1,1) |

| RoleName | NVARCHAR(20) | NOT NULL, UNIQUE |



Additional constraint:

\- RoleName must be either 'Organiser' or 'Participant'.



\## 2. Users



Stores account and profile information for both roles.



| Column | SQL Server Type | Rules |

|---|---|---|

| UserID | INT | Primary key, IDENTITY(1,1) |

| RoleID | INT | NOT NULL, foreign key to Roles.RoleID |

| FirstName | NVARCHAR(100) | NOT NULL |

| LastName | NVARCHAR(100) | NOT NULL |

| Email | NVARCHAR(256) | NOT NULL, UNIQUE |

| PasswordHash | NVARCHAR(512) | NOT NULL |

| DateOfBirth | DATE | NOT NULL |

| PhoneNumber | NVARCHAR(20) | NULL |

| ProfilePictureUrl | NVARCHAR(2048) | NULL |

| CreatedAt | DATETIME2(0) | NOT NULL, DEFAULT SYSUTCDATETIME() |



\## Relationship: Roles and Users



\- Each user must have exactly one role.

\- A role can be assigned to zero or many users.

\- Cardinality: Roles (1) to Users (0..many).

\- Users.RoleID references Roles.RoleID.

\- Deleting a role that is assigned to users is blocked.



\## Application Rules



\- Store password hashes only, never plaintext passwords.

\- Normalise email addresses consistently before storage and login.

\- Validate required names and email format.

\- Reject dates of birth in the future.

\- Users may view and update only their own profile.

\- Profile updates must not allow users to change their role.

\- ProfilePictureUrl stores an image URL, not the image itself.

\- In Part 3, profile images will be uploaded through the API

&#x20; and stored in Azure Blob Storage.



\## Design Status



Roles and Users are defined.

Events, Categories, Enrolments, and Results will be added next.

