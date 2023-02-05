--SELECT idnr, name, login, program, branch FROM BasicInformation ORDER BY idnr;
CREATE VIEW BasicInformation AS
    SELECT idnr, Students.name, login, Students.program, branch
    FROM Students, StudentBranches
    WHERE student = idnr;


--SELECT student, course, grade, credits FROM FinishedCourses ORDER BY student;
CREATE VIEW FinishedCourses AS
    SELECT student, course, grade, Courses.credits as credits   
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

create view countMathCredits AS
    SELECT student, SUM(PassedCourses.credits) AS mathCredits   
    FROM PassedCourses, Classified
    WHERE PassedCourses.course = Classified.code AND Classified.classification LIKE 'math'
    GROUP BY student;


CREATE VIEW countSeminarCredits AS
    SELECT student, SUM(PassedCourses.credits) AS mathCredits   
    frFROMom PassedCourses, Classified
    WHERE PassedCourses.course = Classified.code AND Classified.classification LIKE 'seminar'
    GROUP BY student;

CREATE VIEW AllMandatory AS
    SELECT 
    code FROM MandatoryProgram 
    UNION 
    course FROM MandatoryBranch 
    WHERE MandatoryBranch.program = MandatoryProgram.program
-- if passedCourses.course = Classified.code
 --select course from PassedCourses; -- if course same code as classificaiont in math


/*
create view countMathCourses AS
    SELECT student, SUM(PassedCourses.credits) AS mathCredits
    FROM PassedCourses, Classified
    where Classified.classification like 'math'
    GROUP BY student;
-- sums all the students 
*/


/*
--SELECT student, totalCredits, mandatoryLeft, mathCredits, researchCredits, seminarCourses, qualified FROM PathToGraduation ORDER BY student;
CREATE VIEW PathToGraduation AS 
    SELECT 1,
    SUM(PassedCourses.credits),
    COUNT(UnreadMandatory.course),
    SUM(credits) INTERSECT SELECT Classified.classification = 'math', 
    SUM(credits) INTERSECT SELECT Classified.classification = 'research',
    COUNT(PassedCourses.course) INTERSECT SELECT Classified.classification = 'research', 
    CASE WHEN
        mandatoryLeft IS NULL AND UnreadMandatory IS NOT NULL 
        AND seminarCourses > 0 
        AND SUM(PassedCourses.credits) >=10 
        AND mathCredits >= 20 
        AND researchCredits >= 10 
        AND seminarCourses
    IS NULL THEN "False" ELSE "True"
    END
    FROM Taken, Courses
    WHERE student = Taken.student AND taken.course = code AND student.idnr = taken.student AND Classified.course = code;
*/  