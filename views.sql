--SELECT idnr, name, login, program, branch FROM BasicInformation ORDER BY idnr;

CREATE VIEW BasicInformation AS
    SELECT Students.name, idnr, login, Students.program, branch
    FROM Students, StudentBranches
    WHERE student = idnr;

    
--SELECT student, course, grade, credits FROM FinishedCourses ORDER BY student;




--SELECT student, course, credits FROM PassedCourses ORDER BY student;
CREATE VIEW PassedCourses AS
    SELECT student, course, credits
    FROM  Taken, Courses
    WHERE course = code;


--SELECT student, course, status FROM Registrations ORDER BY student;
CREATE VIEW Registrations AS
    SELECT student, course, capacity
    FROM WaitingList, LimitedCourses;

--SELECT student, course FROM UnreadMandatory ORDER BY student;
CREATE VIEW UnreadMandatory AS
    SELECT student, course
    FROM Taken, MandatoryProgram
    WHERE code != course;