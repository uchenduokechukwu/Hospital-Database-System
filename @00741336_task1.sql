create database JRHospital
use JRHospital

create table UsersLogin(
UserID int identity(1,1) primary key, -- Unique identifier for each user
Username nvarchar(50) not null,
PatientID int not null, -- Foreign key referencing the PatientID in the Patients table
Password binary(64) not null,
salt uniqueidentifier)
 --ensure usernames are unique
alter table UsersLogin add constraint uc_username unique(username)
--foreign key constraint on the PatientID column referencing the Patients table
alter table Users add constraint uc_PatientID foreign key(PatientID) references Patients(PatientID)

create table Patients (
PatientID int identity(1,1) primary key, -- Unique identifier for each patient
FirstName nvarchar(30) not null,
MiddleName nvarchar(30) NULL, 
LastName nvarchar(30) NOT NULL, 
AddressID int NOT NULL, 
EmailAddress  nvarchar(100) UNIQUE NULL CHECK (EmailAddress LIKE '%_@_%._%'), -- Unique email address of the patient (optional)
Telephone nvarchar(20) NOT NULL,
DateOfBirth date NOT NULL, 
Insurance nvarchar(20) NULL, 
DateLeft date NULL)
ALTER TABLE Patients ADD CONSTRAINT fk_addresses FOREIGN KEY (AddressID) REFERENCES Addresses
(AddressID)


create table Addresses (
AddressID int IDENTITY(1,1) NOT NULL PRIMARY KEY,
Address1 nvarchar(50) NOT NULL, 
Address2 nvarchar(50) NULL,
City nvarchar(50) NULL,
Postcode nvarchar(10) NOT NULL,
CONSTRAINT UC_Address UNIQUE (Address1, Postcode))

create table MedicalRecords(
MedicalRecordID int identity(1,1) not null primary key ,
PatientID int not null,
AppointmentID int not null,
Diagnoses nvarchar(100) not null,
Allergies nvarchar(50) null)
alter table MedicalRecords add constraint fk_AppointmentID foreign key(AppointmentID) references PastAppointments(AppointmentID)
alter table MedicalRecords add constraint fj_PatientID foreign key(PatientID) references Patients(PatientID)

create table MedicinesPrescribed (
MedicalRecordID int not null,
Medicine nvarchar(100) not null,
constraint fk_medicineprescribed_medicalrecordID foreign key(MedicalRecordID) references MedicalRecords(MedicalRecordID))

create table Doctors(
DoctorID int identity(1,1) not null primary key, --unique identifier for each doctor
FirstName nvarchar(30) not null,
MiddleName nvarchar(30) NULL, 
LastName nvarchar(30) NOT NULL,  
Specialty nvarchar(60) not null,
DepartmentID int not null,
Telephone nvarchar(20) not null,
StartTime time,
EndTime time)
alter table Doctors add constraint fk_departmentID foreign key(DepartmentID) references Doctors_Department(DepartmentID)

create table Doctors_Department(
DepartmentID int identity(1,1) not null primary key,
DepartmentName nvarchar(50) not null,
DepartmentTelephone nvarchar(20) not null)

create table CurrentAppointments(
AppointmentID int identity(1,1) not null primary key,
PatientID int not null,
DoctorID int not null,
AppointmentDate date not null,
AppointmentTime time not null,
Status nvarchar(20) not null,
Review nvarchar(max) null)
alter table CurrentAppointments add constraint fk_patientID foreign key(PatientID) references Patients(PatientID)
alter table CurrentAppointments add constraint fj_DoctorID foreign key(DoctorID) references Doctors(DoctorID)
alter table currentappointments add constraint CK__CurrentApts check(status in('Available', 'Completed', 'Pending', 'Cancelled'))

create table PastAppointments(
AppointmentID int identity(1,1) not null primary key,
PatientID int not null,
AppointmentDate date not null,
AppointmentTime time not null,
DoctorID int not null,
Review nvarchar(max) null)
alter table PastAppointments add constraint fk_doctorID foreign key(DoctorID) references Doctors(DoctorID)
alter table PastAppointments add constraint fg_patientID foreign key(PatientID) references Patients(PatientID)

--inserting into the address table
insert into Addresses(Address1, Address2, City, Postcode)
values('97 Haughton Green Rd', 'Denton', 'Manchester', 'M34 7GR'),
('18 Cross St', null, 'Manchester', 'M2 7AE'),
('1 New York St', null, 'Manchester', 'M1 4HD'),
('338 Palatine Rd', 'Wythenshawe', 'Manchester', 'M22 4HE'),
('459 Bury New Rd', 'Prestwich', 'Manchester', 'M25 1AF'),
('103 Oxford Rd', null, 'Manchester', 'M1 7ED'),
('2 Hardman St', null, 'Manchester', 'M3 3HF'),
('5 Emerald Street', null, 'Keighley', 'BD22 7BW'), 
('16 Oldhamn rd', null, 'Manchester', 'M44 2AF'),
('Salford', null, 'Manchester', 'M6')
select * from Addresses

CREATE PROCEDURE uspAddPatient @firstname nvarchar(30), @middlename nvarchar(30), @lastname nvarchar(30), @address int, 
@emailaddress nvarchar(100), @telephone nvarchar(20), @dateofbirth date, @insurance nvarchar(20), @dateleft date
 AS
DECLARE @salt UNIQUEIDENTIFIER=NEWID()
 INSERT INTO Patients(FirstName, MiddleName, LastName, AddressID, EmailAddress, Telephone, DateOfBirth, Insurance, DateLeft)
VALUES(@firstname, @middlename, @lastname, @address, @emailaddress, @telephone, @dateofbirth, @insurance, @dateleft)
--inserting into the patients table
EXECUTE uspAddPatient @firstname = 'Magaret', @middlename = null, @lastname = 'Antoine', @address = 10, @emailaddress = 'mantoine@gmail.com',
@telephone = '07342218907', @dateofbirth = '1990-03-22', @insurance = null, @dateleft = null;
select * from Patients

CREATE PROCEDURE uspAddUsers  @username NVARCHAR(50),  @PatientID int, @password NVARCHAR(50)
 AS
DECLARE @salt UNIQUEIDENTIFIER=NEWID()
 INSERT INTO UsersLogin(Username, PatientID, Password, salt)
VALUES( @username,  @patientID, HASHBYTES('SHA2_512', @password+CAST(@salt AS NVARCHAR(36))), @salt)
--inserting into users login table
EXECUTE uspAddUsers @username = 'magaretantoine', @patientID = 10, @password = '8732'

insert into Doctors_Department(DepartmentName, DepartmentTelephone)
values('Gastroenterology',  '0161 654 9920'),
('Cardiology', '0161 889 7092'),
('Psychiatry', '0161 455 9076'),
('Oncology', '0161 490 6574'),
('Pediatric', '0161 897 5523')
insert into Doctors_Department(DepartmentName, DepartmentTelephone)
values('Orthopedics', '0161 953 8872'),
('Radiology', '0161 648 3732')
select * from Doctors_Department

insert into Doctors(FirstName, MiddleName, LastName, Telephone, DepartmentID, Specialty, StartTime, EndTime)
values('Chukwudi', 'Gabriel', 'Okwuchi', '07363280081', 1, 'Digestive system disorders and treatments', '00:00:00', '11:59:59'),
('Sam', 'Bridge', 'Nero', '07389634508', 1, 'Digestive system disorders and treatments', '12:00:00', '23:59:59'),
('Lim', 'Andrea', 'Chan', '07344569086', 3, ' Mental health disorders and treatments', '00:00:00', '11:59:59'),
('Precious', 'Kemi', 'Adetayo', '07380994532', 3, 'Mental health disorders and treatments', '12:00:00', '23:59:59'),
('Pius', 'Ebere', 'Mendoza', '07399876005', 4, 'Diagnosis, treatment, and prevention of cancer', '00:00:00', '11:59:59'),
('Mary', 'Anne', 'Asher-Smith', '07384352212', 4, 'Diagnosis, treatment, and prevention of cancer',  '12:00:00', '23:59:59'),
('Lucia', 'Maria', 'Carmona', '07367312990', 2,'Heart disease and conditions',  '00:00:00', '11:59:59'),
('Borges', 'Christian', 'Quaresma', '07344879009', 2, 'Heart disease and conditions', '12:00:00', '23:59:59'),
('Gabriel', 'Lucas', 'Pavard', '07344908623', 5, 'Medical care for children', '00:00:00', '11:59:59'),
('Patience', 'Ngozie', 'Jiya', '07344219908',  5, 'Medical care for children', '12:00:00', '23:59:59'),
('Bruno', 'Ed', 'Octavio', '07390074321', 6, 'Musculoskeletal conditions', '00:00:00', '11:59:59'),
('Phyllis', 'Jane', 'Halpert', '07366543209', 6, 'Musculoskeletal conditions', '12:00:00', '23:59:59'),
('Dwight', 'Downing', 'Gamst', '07345908872', 7, 'Ultrasound', '00:00:00', '11:59:59'),
('Justin', 'Beemer', 'Croft', '07356720098', 7, 'Ultrasound', '12:00:00', '23:59:59')
select * from Doctors

insert into CurrentAppointments(PatientID, DoctorID, AppointmentDate, AppointmentTime, Status)
values(5, 2, '2024-05-01', '14:00:00', 'Pending'),
(8, 3, '2024-05-30', '08:00:00', 'Pending'),
(10,6, '2024-05-22', '14:00:00', 'Pending'),
(3, 7, '2024-06-06', '14:00:00', 'Pending'),
(1, 9, '2024-05-15', '08:00:00', 'Pending'),
(9, 1, '2024-04-30', '08:00:00', 'Pending'),
(7,10, '2024-06-19', '14:00:00', 'Pending'),
(6, 13, '2024-05-14', '08:00:00', 'Pending')
select * from CurrentAppointments

insert into PastAppointments(AppointmentDate, AppointmentTime, DoctorID, PatientID, Review)
values('2023-09-24', '08:00:00', 7, 7, 'Very good'),
('2023-11-19', '14:00:00', 2, 3, 'Excellent'),
('2024-02-26', '14:00:00', 4, 2, 'Excellent'),
('2023-05-18', '08:00:00', 5, 4, 'Fair'),
('2024-01-08', '14:00:00', 4, 10, 'Very good'),
('2023-09-12', '08:00:00', 1, 6, 'Excellent'),
('2022-11-18', '14:00:00', 8, 1, 'Very good'),
('2023-09-22', '14:00:00', 2, 7, 'Excellent'),
('2024-02-21', '08:00:00', 5, 9, 'Very good'),
('2022-06-05', '14:00:00', 6, 4, 'Fair'),
('2023-11-19', '08:00:00', 9, 5, 'Excellent'),
('2024-01-27', '14:00:00', 10, 3, 'Very good'),
('2023-02-19', '14:00:00', 14, 2, 'Excellent'),
('2023-09-30', '08:00:00', 11, 1, 'Very good')
select * from PastAppointments

insert into MedicalRecords(PatientID, AppointmentID, Diagnoses, Allergies)
values(4, 4, 'Prostate Cancer', Null),
(9, 9, 'Skin Cancer', 'Sunscreen'),
(2, 3, 'Depression', null),
(3, 12, 'Asthma', 'Nuts'),
(5, 11, 'Eczema', 'Detergents'),
(10, 5, 'Constipation', null),
(1, 7, 'Hypertension', 'Cats'),
(7, 1, 'Heart Failure', null),
(3, 2, 'Irritable Bowel Syndrome', 'Nuts'),
(6, 6, 'Gallstones', 'Soot'),
(7,8, 'Irritable Bowel Syndrome', null),
( 4,10, 'Skin Cancer', null),
(2,13, 'Fractured rib', null),
(1, 14, 'Dislocated Knee', null)
select * from MedicalRecords

insert into MedicinesPrescribed(MedicalRecordID, Medicine)
values(1, 'Leuprolide'),
(1, 'Bicalutamide'),
(2, 'Fluorouracil'),
(3, 'Sertraline (Zoloft)'),
(4, 'Fluticasone (Flovent)'),
(4, 'Budesonide (Pulmicort)'),
(5, 'Diphenhydramine (Benadryl)'),
(5, 'Hydrocortisone Cream'),
(6, 'Lactulose'),
(7, 'Lisinopril'),
( 7, 'Enalapril'),
(8, 'Spironolactone'),
(8, 'Eplerenone'),
(9, 'Dicyclomine'),
(9, 'Hyoscyamine'),
(10, 'Interferon'),
(10, 'Ribavirin'),
(10, 'Sofosbuvir'),
(11, 'Dicyclomine'),
(11, 'Hyoscyamine'),
(12, 'Fluorouracil'),
(13, 'Ibuprofen'),
(13, 'Calcium'),
(13, 'Vitamin D'),
(14, 'Ibuprofen'),
(14, 'Oxycodone')
select * from medicinesprescribed

-- 2. constraint that checks date on current appointments
ALTER TABLE CurrentAppointments add  constraint Ck_AppointmentDate Check (AppointmentDate >= cast(getdate() as date))

---List all the patients with older than 40 and have Cancer in diagnosis.
select distinct p.FirstName, p.MiddleName, p.LastName from Patients p
inner join MedicalRecords m on p.PatientID =  m.PatientID
-- 3. Filter the results to include only patients who are over 40 years old and have been diagnosed with cancer
Where Datediff(year, p.DateOfBirth, getdate()) > 40
and m.Diagnoses like '%Cancer%'

--- 4.Search the database of the hospital for matching character strings by name of medicine. Results should be sorted with most recent medicine prescribed date first.
create procedure SearchMedicineByName @medicinename nvarchar(100)
As
Begin
set nocount on;
select r.medicalrecordID, m.medicine, p.appointmentdate as PrescribedDate
from medicalrecords r
join medicinesprescribed m on r.medicalrecordID = m.medicalrecordID
join pastappointments p on r.appointmentID = p.appointmentID
  -- Filter the results to include only medicines that contain the specified medicine name
Where m.medicine like '%' + @medicinename + '%'
-- Order the results by appointment date in descending order
order by p.appointmentdate desc;
end;

EXEC SearchMedicineByName @MedicineName = 'A';

--- 5. Return a full list of diagnosis and allergies for a specific patient who has an appointment today
 create procedure TodaysAppointment @patientID tinyint
As
Begin
set nocount on;  -- Prevents the count of rows affected by a Transact-SQL statement from being returned as part of the result set.
declare @today date = cast(getdate() as date);
select  a.PatientID, a.appointmentdate, r.diagnoses, r.allergies 
from medicalrecords r
join currentappointments a on r.patientID = a.PatientID
 -- Filter the results to include only appointments for the specified patient on today's date
where r.patientID = @patientID and cast(a.appointmentdate as date) = @today;
end;

exec TodaysAppointment @patientID = 10

---6. Update the details for an existing doctor
Create procedure uspupdatedoctors @doctorID tinyint, @firstname nvarchar(30), @middlename nvarchar(30), @lastname nvarchar(30), 
@specialty nvarchar(50), @departmentID tinyint, @telephone nvarchar(20), @starttime time, @endtime time
as 
begin
set nocount on;
update doctors
set Firstname = @firstname,
MiddleName = @middlename,
LastName = @lastname,
Specialty = @specialty,
DepartmentID = @departmentID,
Telephone = @telephone,
StartTime = @starttime,
EndTime = @endtime
where DoctorID = @doctorID -- Filter the update to the specific doctor using DoctorID
end;

EXEC uspupdatedoctors 
	@doctorID = 10,
    @firstname = 'Patience',
    @middlename = 'Ngozi',
    @lastname = 'Jiya',
    @specialty = 'Medical care for children',
    @departmentID = 5,
    @telephone = '07344219908',
    @starttime = '12:00:00',
    @endtime = '23:59:59'

	---7. Delete the appointment who status is already completed.
	create trigger appointment_delete 
on currentappointments
after delete 
as begin
-- Insert deleted appointment records into the PastAppointments table
insert into PastAppointments(PatientID, DoctorID, AppointmentDate, AppointmentTime, Review)
select p.PatientID, p.DoctorID, p.AppointmentDate, p.AppointmentTime, p.Review
from deleted p -- "deleted" is a special table in triggers that holds the rows affected by the delete operation
end;

create procedure completedappointment 
as 
begin
set nocount on;
delete from CurrentAppointments
where Status = 'Completed'; -- Filter appointments by status 'Completed'
end;

--updating current appointments to test the trigger
update CurrentAppointments
set status = 'Completed',
AppointmentDate = '2024-04-07',
Review = 'Excellent'
where patientID = 6

exec completedappointment

--- 8. View containing all the required information of Doctors
create view DoctorsSummary 
(DoctorID, FirstName, LastName, Specialty, DepartmentID, DepartmentName, DepartmentTelephone, CurrentAppointmentID, 
PastAppointmentID, CurrentAppointmentDate, PastAppointmentDate, CurrentAppointmentTime, PastAppointmentTime, Review)
as
select
d.doctorID, d.firstname, d.lastname, d.specialty,  d.departmentID, t.departmentname, t.departmenttelephone, c.appointmentID, p.appointmentID,
c.appointmentdate, p.appointmentdate, c.appointmenttime, p.appointmenttime, p.review
from Doctors d inner join Doctors_Department t on d.departmentID = t.departmentID
inner join PastAppointments p on d.doctorID = p.doctorID
inner join CurrentAppointments c on c.doctorID = p.doctorID

select * from DoctorsSummary

--- 9. Create a trigger so that the current state of an appointment can be changed to available when it is cancelled.
create trigger CancelledAppointments
on currentappointments
after update
as
begin
set nocount on;
-- Check if the "status" column was updated
if update(status)
begin
update c 
set c.status = 'Available' -- Set status to 'Available' for cancelled appointments
from currentappointments as c
inner join inserted as i on  c.appointmentID = i.AppointmentID
where i.status= 'Cancelled'; -- Filter for updated appointments with status 'Cancelled'
end
end;

--updating current appointments to test the trigger
update currentappointments
set status = 'Cancelled'
where patientID = 3

--- 10. Query which allows the hospital to identify the number of completed appointments with the specialty of doctors as ‘Gastroenterologists’.
select d.Departmentname, count(*) as No_of_Appointments
from Doctors_Department d inner join Doctors dr  on d.DepartmentID = dr.DepartmentID
inner join PastAppointments pa on dr.DoctorID = pa.DoctorID
where departmentname like 'G%' -- Filter departments whose name starts with 'G'
group by departmentname

---system define function
--- 11. 'datediff' calculates the difference between days
select DoctorID, FirstName, LastName, Specialty, datediff(d, PastAppointmentDate, CurrentAppointmentDate) 
as NumberOfDaysBetweenAppointments from DoctorsSummary

--- 12. SELECT queries which make use of joins and sub-queries.
select p.PatientID, p.FirstName + ' ' + isnull(p.MiddleName,'') + ' ' + p.LastName as FullName, AppointmentID, 
AppointmentDate, AppointmentTime, d.DoctorID, d.FirstName + ' ' + isnull(d.MiddleName,'') + ' ' + d.LastName as Doctor, d.Specialty from Patients p
inner join CurrentAppointments c on p.PatientID = c.PatientID
inner join Doctors d on c.DoctorID = d.DoctorID
where p.PatientID in(select m.PatientID from medicalrecords  -- Subquery to select patient IDs diagnosed with cancer from medical records
inner join medicalrecords m on c.PatientID = m.PatientID
where m.Diagnoses like '%Cancer%')

--- 13. View of Patient full details
create view PatientFullDetails
(PatientID, FullName, EmailAddress, Telephone, FullAddress,DateofBirth, Insurance)
as
select p.patientID, p.FirstName + ' ' + isnull(p.MiddleName,'') + ' ' + p.LastName as FullName, p.EmailAddress, p.Telephone, 
a. Address1 + ' ' + isnull(a.Address2,'') + ' ' + a.City + ' ' + a.Postcode as FullAddress, p.DateofBirth, p.Insurance
from Patients p join Addresses a on p.AddressID = a.AddressID

select * from PatientFullDetails

--- 14. Procedure that checks doctors availability
create procedure DoctorsAvailability @starttime time, @endtime time
as 
begin
set nocount on;
select DoctorID,
Firstname, 
MiddleName,
LastName,
Specialty,
DepartmentID,
Telephone
from Doctors
where Starttime <= @endtime  -- Filter doctors whose availability starts before or at the end time
      and Endtime >= @starttime    -- Filter doctors whose availability ends after or at the start time
end;

EXEC DoctorsAvailability '09:00:00', '11:00:00'

---Trigger

create trigger deletepatient on patients
instead of delete 
as begin
declare @id int;
declare @count int;
-- Check if the patient ID exists in the Patients table
select @id = count(*) from Patients where PatientID = @id
 -- If the patient ID exists, delete the patient record
if @count = 0
delete from Patients where PatientID = @id
else 
-- If the patient ID does not exist, raise an error
throw 50000, 'You do not have the permission to delete this patient', 1;
end;

delete from Patients where PatientID = 2

---User defined function
create function MedicinesPrescribedForPatient()
Returns Table
as
return
(select p.PatientID, p.FirstName, p.LastName, m.Medicine 
from Patients p inner join Medicalrecords mr on p.PatientID = mr.PatientID
inner join MedicinesPrescribed m on  mr.MedicalRecordID = m.MedicalRecordID)

select * from MedicinesPrescribedForPatient()
