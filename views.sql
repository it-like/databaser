--SELECT idnr, name, login, program, branch FROM BasicInformation ORDER BY idnr;

CREATE VIEW BasicInformation AS
    SELECT Students.name, idnr, login, Students.program, branch
    FROM Students, StudentBranches
    WHERE student = idnr;

    
--SELECT student, course, grade, credits FROM FinishedCourses ORDER BY student;
