Hospital Database System Project

This project involves the design and implementation of a hospital database system using T-SQL in Microsoft SQL Server Management Studio (SSMS). The system manages patient registration, appointments, medical records, and doctor feedback.

Features

Normalized Database: Designed up to 3NF.

Tables: Includes Patients, Doctors, Appointments, MedicalRecords, Departments, and UsersLogin.

Stored Procedures: For updating doctor details and deleting completed appointments.

Views: Consolidates past and current appointment information.

Triggers: Automatically updates appointment availability when cancelled.

Constraints: Ensures data integrity, including unique usernames and valid appointment dates.

Setup Instructions

Create the database using CREATE DATABASE JRHospital;.

Run the provided SQL scripts in the following order:

create_tables.sql

insert_data.sql

create_views.sql

stored_procedures.sql

functions.sql

triggers.sql

Example Query

List patients older than 40 with a diagnosis of Cancer:

SELECT FirstName, LastName, DateOfBirth, Diagnosis
FROM Patients
JOIN MedicalRecords ON Patients.PatientID = MedicalRecords.PatientID
WHERE Diagnosis = 'Cancer' AND DATEDIFF(YEAR, DateOfBirth, GETDATE()) > 40;

Author

Uchendu Okechukwu

For any questions or feedback, please feel free to contact me through GitHub.
