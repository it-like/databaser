--SELECT idnr, name, login, program, branch FROM BasicInformation ORDER BY idnr;

CREATE VIEW BasicInformation AS
    SELECT Students.name, idnr, login, Students.program, branch
    FROM Students, StudentBranches
    WHERE student = idnr;

    
--SELECT student, course, grade, credits FROM FinishedCourses ORDER BY student;

CREATE VIEW FinishedCourses AS
    SELECT student, course, grade, Courses.credits
    FROM Taken, Students, Courses
    Where student = Students.idnr AND course = Courses.code AND credits = Courses.credits;

--SELECT student, course, credits FROM PassedCourses ORDER BY student;
CREATE VIEW PassedCourses AS
    SELECT student, course, credits
    FROM  Taken, Courses
    WHERE course = code AND grade NOT IN ('U');


--SELECT student, course, status FROM Registrations ORDER BY student;
CREATE VIEW Registrations AS
    SELECT student, course, 'waiting' AS status FROM WaitingList
        UNION
    SELECT student, course, 'registered' AS status FROM Registered;
    
--SELECT student, course FROM UnreadMandatory ORDER BY student;
CREATE VIEW UnreadMandatory AS
    SELECT student, course
    FROM Taken, MandatoryProgram
    WHERE code != course;

--SELECT student, totalCredits, mandatoryLeft, mathCredits, researchCredits, seminarCourses, qualified FROM PathToGraduation ORDER BY student;
CREATE TABLE PathToGraduation AS
SELECT idnr, --student
SUM(credits), --totalcredits
UnreadMandatory.course,
SUM(credits) INTERSECT SELECT Classified.classification = 'math', --mathcredits
SUM(credits) INTERSECT SELECT Classified.classification = 'research',--research credits
COUNT(PassedCourses.course) INTERSECT SELECT Classified.classification = 'research'
couse FROM PassedCourses IN code FROM MandatoryProgram
AND SUM(PassedCourses.credits) >=10 AND mathCredits >= 20 AND researchCredits >= 10 AND seminarCourses
FROM BasicInformation, Courses, Taken
WHERE taken.course = code AND student.idnr = taken.student AND Classified.course = code