CREATE DATABASE SoftwareCompanyDB;
USE SoftwareCompanyDB;

-- Software Projects Table
CREATE TABLE SoftwareProjects (
    ProjectID INT PRIMARY KEY,
    ProjectName VARCHAR(255),
    ProjectDescription TEXT,
    ProjectDeadline DATE
);

-- Client Information Table
CREATE TABLE ClientInformation (
    ClientID INT PRIMARY KEY,
    ClientName VARCHAR(255),
    ContactPersonName VARCHAR(255),
    ContactEmail VARCHAR(255)
);

-- Company Employees Table
CREATE TABLE CompanyEmployees (
    EmployeeID INT PRIMARY KEY,
    EmployeeName VARCHAR(255)
);

-- Project Team Members Table
CREATE TABLE ProjectTeamMembers (
    ProjectID INT,
    EmployeeID INT,
    PRIMARY KEY (ProjectID, EmployeeID),
    FOREIGN KEY (ProjectID) REFERENCES SoftwareProjects(ProjectID),
    FOREIGN KEY (EmployeeID) REFERENCES CompanyEmployees(EmployeeID)
);

-- Project Team Leads Table
CREATE TABLE ProjectTeamLeads (
    ProjectID INT,
    EmployeeID INT,
    IsTeamLead BOOLEAN,
    PRIMARY KEY (ProjectID, EmployeeID),
    FOREIGN KEY (ProjectID) REFERENCES SoftwareProjects(ProjectID),
    FOREIGN KEY (EmployeeID) REFERENCES CompanyEmployees(EmployeeID)
);

-- Insert Data into SoftwareProjects
INSERT INTO SoftwareProjects (ProjectID, ProjectName, ProjectDescription, ProjectDeadline) VALUES
(1, 'CRM System', 'A system to manage customer relationships', '2024-11-15'),
(2, 'HR Management Tool', 'Tool for managing employee records and payroll', '2024-09-30'),
(3, 'Analytics Dashboard', 'Dashboard for data analysis and visualization', '2024-10-20'),
(4, 'Billing Software', 'Software for handling invoicing and payments', '2024-12-10'),
(5, 'Project Management App', 'App for tracking project progress and tasks', '2024-08-25');

-- Insert Data into ClientInformation
INSERT INTO ClientInformation (ClientID, ClientName, ContactPersonName, ContactEmail) VALUES
(1, 'Tech Innovators', 'Emily Carter', 'emily.carter@techinnovators.com'),
(2, 'Healthcare Solutions', 'John Smith', 'john.smith@healthcaresolutions.com'),
(3, 'Financial Services Inc.', 'Laura Chen', 'laura.chen@financialservices.com'),
(4, 'Retail Partners', 'Michael Johnson', 'michael.johnson@retailpartners.com'),
(5, 'Education Today', 'Sophia Martinez', 'sophia.martinez@educationtoday.com');

-- Insert Data into CompanyEmployees
INSERT INTO CompanyEmployees (EmployeeID, EmployeeName) VALUES
(1, 'Ethan Roberts'),
(2, 'Ava White'),
(3, 'James Wilson'),
(4, 'Olivia Davis'),
(5, 'Benjamin Clark'),
(6, 'Emma Lewis');

-- Insert Data into ProjectTeamMembers
INSERT INTO ProjectTeamMembers (ProjectID, EmployeeID) VALUES
(1, 1),
(1, 6),
(2, 2),
(2, 4),
(3, 3),
(3, 5),
(4, 2),
(4, 6),
(5, 1),
(5, 5);

-- Queries
--1. Find all projects with a deadline before December 10th, 2024
SELECT * FROM SoftwareProjects WHERE ProjectDeadline < '2024-12-10';

--2. List all projects for "Tech Innovators" ordered by deadline
SELECT * FROM SoftwareProjects
WHERE ProjectID IN (
    SELECT ProjectID
    FROM ClientInformation
    WHERE ClientName = "Tech Innovators"
)
ORDER BY ProjectDeadline DESC;

--3. Find the team lead for the "HR Management Tool" project.
SELECT * FROM ProjectTeamLeads WHERE ProjectID = 2 AND IsTeamLead = TRUE;

--4. Find projects containing "Dashboard" in the name.
SELECT * FROM SoftwareProjects
WHERE ProjectName LIKE '%Dashboard%';

--5. Count the number of projects assigned to Ava White.
SELECT COUNT(*) FROM ProjectTeamMembers
WHERE EmployeeID = 2;

--6. Find the total number of employees working on each project.
SELECT ProjectID, COUNT(EmployeeID)
FROM ProjectTeamMembers
GROUP BY ProjectID;

--7. Find all clients with projects having a deadline after October 20th, 2024.
SELECT ClientName
FROM ClientInformation
WHERE ClientID IN (
    SELECT ClientID
    FROM SoftwareProjects
    WHERE ProjectDeadline > '2024-10-20'
);

--8. List employees who are not currently team leads on any project.
SELECT * FROM CompanyEmployees
WHERE EmployeeID NOT IN (
    SELECT EmployeeID
    FROM ProjectTeamLeads
    WHERE IsTeamLead = TRUE
);

--9. Combine a list of projects with deadlines before December 10th and another list with "Billing" in the project name
SELECT *
FROM SoftwareProjects
WHERE ProjectDeadline < '2024-12-10'
UNION
SELECT *
FROM SoftwareProjects
WHERE ProjectName LIKE '%Billing%';

--10. Display a message indicating if a project is overdue (deadline passed).
SELECT
ProjectName,
ProjectDeadline,
CASE
WHEN ProjectDeadline < CURRENT_DATE THEN 'Overdue'
ELSE 'Not overdue'
END AS Status
FROM SoftwareProjects;

--11. Create a view to simplify retrieving client contact information
CREATE VIEW ClientContact AS
SELECT
ClientID,
ClientName,
ContactPersonName
FROM ClientInformation;

--12. Create a view to show only ongoing projects (not yet completed).
CREATE VIEW OngoingProjects AS
SELECT
ProjectID,
ProjectName,
ProjectDescription,
ProjectDeadline
FROM SoftwareProjects
WHERE ProjectDeadline >= CURRENT_DATE;

--13. Create a view to display project information along with assigned team leads.
CREATE VIEW ProjectInformation AS
SELECT CompanyEmployees.EmployeeName, SoftwareProjects.ProjectName, SoftwareProjects.ProjectDeadline
FROM
ProjectTeamLeads
JOIN CompanyEmployees ON ProjectTeamLeads.EmployeeID = CompanyEmployees.EmployeeID
AND ProjectTeamLeads.IsTeamLead = TRUE
JOIN SoftwareProjects ON ProjectTeamLeads.ProjectID = SoftwareProjects.ProjectID;

--14. Create a view to show project names and client contact information for projects with a deadline in November 2024.
CREATE OR REPLACE VIEW ProjectClientNovember AS
SELECT SoftwareProjects.ProjectName, SoftwareProjects.ProjectDeadline, ClientInformation.ContactPersonName, ClientInformation.ClientName
FROM SoftwareProjects
JOIN ClientInformation ON SoftwareProjects.ClientID = ClientInformation.ClientID
WHERE ProjectDeadline BETWEEN '2024-11-01' AND '2024-11-30';

--15. Create a view to display the total number of projects assigned to each employee.
CREATE OR REPLACE VIEW EmployeeProjectCount AS
SELECT CompanyEmployees.EmployeeID, CompanyEmployees.EmployeeName, COUNT(ProjectTeamMembers.ProjectID) AS ProjectsAssigned
FROM CompanyEmployees
JOIN ProjectTeamMembers ON ProjectTeamMembers.EmployeeID = CompanyEmployees.EmployeeID
GROUP BY
CompanyEmployees.EmployeeID,
CompanyEmployees.EmployeeName;

-- 16. Create a function to calculate the number of days remaining until a project deadline.
DELIMITER $$

CREATE FUNCTION DaysUntilDeadline(ProjectID INT)
RETURNS INT DETERMINISTIC
BEGIN
DECLARE deadline DATE;
DECLARE days_remaining INT;

    SELECT ProjectDeadline INTO deadline
    FROM SoftwareProjects
    WHERE ProjectID = ProjectID;

    SET days_remaining = DATEDIFF(deadline, CURRENT_DATE);

    RETURN days_remaining;

END$$

DELIMITER ;
-- Usage
SELECT DaysUntilDeadline(1) AS DaysRemaining;

-- 17. Create a function to calculate the number of days a project is overdue
DELIMITER $$

CREATE FUNCTION DaysOverdue(ProjectID INT)
RETURNS INT DETERMINISTIC
BEGIN
DECLARE deadline DATE;
DECLARE overdue_days INT;

    SELECT ProjectDeadline INTO deadline
    FROM SoftwareProjects
    WHERE ProjectID = ProjectID;

    SET overdue_days = DATEDIFF(CURRENT_DATE, deadline);

    IF overdue_days < 0 THEN
        SET overdue_days = 0;
    END IF;

    RETURN overdue_days;

END$$

DELIMITER ;

-- Usage
SELECT DaysOverdue(1) AS OverdueDays
LIMIT 0, 1000;

--18. Create a stored procedure to add a new client and their first project in one call
DELIMITER $$

CREATE PROCEDURE AddClientAndProject(
IN ClientName VARCHAR(255),
IN ContactPersonName VARCHAR(255),
IN ProjectName VARCHAR(255),
IN ProjectDescription TEXT,
IN ProjectDeadline DATE
)
BEGIN
DECLARE ClientID INT;
DECLARE ProjectID INT;

    INSERT INTO ClientInformation (ClientName, ContactPersonName)
    VALUES (ClientName, ContactPersonName);

    SET ClientID = LAST_INSERT_ID();

    INSERT INTO SoftwareProjects (ProjectName, ProjectDescription, ProjectDeadline, ClientID)
    VALUES (ProjectName, ProjectDescription, ProjectDeadline, ClientID);

    SET ProjectID = LAST_INSERT_ID();

    SELECT ProjectID, ClientID, ProjectName, ClientName;

END$$

DELIMITER;

--19. Create a stored procedure to move completed projects (past deadlines) to an archive table
CREATE TABLE IF NOT EXISTS ArchivedProjects (
    ProjectID INT PRIMARY KEY,
    ProjectName VARCHAR(255),
    ProjectDescription TEXT,
    ProjectDeadline DATE,
    ClientID INT,
    ArchivedDate DATE
);

ALTER TABLE ArchivedProjects
ADD CONSTRAINT fk_archive_client FOREIGN KEY (ClientID) REFERENCES ClientInformation (ClientID);

DELIMITER $$

CREATE PROCEDURE ArchiveCompletedProjects()
BEGIN
    INSERT INTO ArchivedProjects (ProjectID, ProjectName, ProjectDescription, ProjectDeadline, ClientID, ArchivedDate)
    SELECT ProjectID, ProjectName, ProjectDescription, ProjectDeadline, ClientID, CURRENT_DATE
    FROM SoftwareProjects
    WHERE ProjectDeadline < CURRENT_DATE;

    DELETE FROM SoftwareProjects
    WHERE ProjectDeadline < CURRENT_DATE;

END$$

DELIMITER ;

-- Usage
CALL ArchiveCompletedProjects();

--20. Create a trigger to log any updates made to project records in a separate table for auditing purposes
CREATE TABLE IF NOT EXISTS ProjectAudit (
    AuditID INT PRIMARY KEY AUTO_INCREMENT,
    ProjectID INT,
    ChangeDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    OldProjectName VARCHAR(255),
    NewProjectName VARCHAR(255),
    OldProjectDescription TEXT,
    NewProjectDescription TEXT,
    FOREIGN KEY (ProjectID) REFERENCES SoftwareProjects(ProjectID)
);

DELIMITER $$

CREATE TRIGGER ProjectUpdateAudit
AFTER UPDATE ON SoftwareProjects
FOR EACH ROW
BEGIN
    INSERT INTO ProjectAudit (ProjectID, OldProjectName, NewProjectName, OldProjectDescription, NewProjectDescription)
    VALUES (OLD.ProjectID, OLD.ProjectName, NEW.ProjectName, OLD.ProjectDescription, NEW.ProjectDescription);
END$$

DELIMITER ;

--21. Create a trigger to ensure a team lead assigned to a project is a valid employee
DELIMITER $$

CREATE TRIGGER ValidateTeamLead
BEFORE INSERT ON ProjectTeamLeads
FOR EACH ROW
BEGIN
    DECLARE is_valid_lead INT;

    SELECT COUNT(*)
    INTO is_valid_lead
    FROM CompanyEmployees
    WHERE EmployeeID = NEW.EmployeeID;

    IF is_valid_lead = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid team lead employee';
    END IF;

END$$

DELIMITER;

--22. Create a view to display project details along with the total number of team members assigned
CREATE VIEW ProjectDetailsWithTeamMembers AS
SELECT
    sp.ProjectID,
    sp.ProjectName,
    sp.ProjectDescription,
    sp.ProjectDeadline,
    ci.ClientName,
    COUNT(ptm.EmployeeID) AS TotalTeamMembers
FROM
    SoftwareProjects sp
JOIN ClientInformation ci ON sp.ClientID = ci.ClientID
LEFT JOIN ProjectTeamMembers ptm ON sp.ProjectID = ptm.ProjectID
GROUP BY
    sp.ProjectID,
    sp.ProjectName,
    sp.ProjectDescription,
    sp.ProjectDeadline,
    ci.ClientName;

SELECT * FROM ProjectDetailsWithTeamMembers;

--23. Create a view to show overdue projects with the number of days overdue
CREATE VIEW OverdueProjects AS
SELECT
    sp.ProjectID,
    sp.ProjectName,
    sp.ProjectDescription,
    sp.ProjectDeadline,
    ci.ClientName,
    DATEDIFF(CURRENT_DATE, sp.ProjectDeadline) AS DaysOverdue
FROM
    SoftwareProjects sp
JOIN ClientInformation ci ON sp.ClientID = ci.ClientID
WHERE
    sp.ProjectDeadline < CURRENT_DATE;

SELECT * FROM OverdueProjects;

--24. Create a stored procedure to update project team members (remove existing, add new ones)
DELIMITER $$

CREATE PROCEDURE UpdateProjectTeam (
    IN p_ProjectID INT,
    IN new_team_members JSON
)
BEGIN
    DELETE FROM ProjectTeamMembers
    WHERE ProjectID = p_ProjectID;

    DECLARE i INT DEFAULT 0;
    DECLARE n INT;
    DECLARE member_id INT;
    DECLARE is_lead BOOLEAN;

    SET n = JSON_LENGTH(new_team_members);

    WHILE i < n DO
        SET member_id = JSON_UNQUOTE(JSON_EXTRACT(new_team_members, CONCAT('$[', i, '].EmployeeID')));
        SET is_lead = JSON_UNQUOTE(JSON_EXTRACT(new_team_members, CONCAT('$[', i, '].IsTeamLead')));

        INSERT INTO ProjectTeamLeads (ProjectID, EmployeeID, IsTeamLead)
        VALUES (p_ProjectID, member_id, is_lead);

        SET i = i + 1;
    END WHILE;

END$$

DELIMITER;

--25. Prevent the deletion of projects with assigned team members using a trigger
DELIMITER $$

CREATE TRIGGER PreventProjectDeletion
BEFORE DELETE ON SoftwareProjects
FOR EACH ROW
BEGIN
    DECLARE team_member_count INT;

    SELECT COUNT(*)
    INTO team_member_count
    FROM ProjectTeamMembers
    WHERE ProjectID = OLD.ProjectID;

    IF team_member_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot delete project: Team members are still assigned to this project.';
    END IF;

END$$

DELIMITER ;
