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

CREATE VIEW CountMathCredits AS
    SELECT student, SUM(PassedCourses.credits) AS sumCredits   
    FROM PassedCourses, Classified
    WHERE PassedCourses.course = Classified.code AND Classified.classification LIKE 'math'
    GROUP BY student;


CREATE VIEW CountResearchCredits AS
    SELECT student, SUM(PassedCourses.credits) AS sumCredits   
    FROM PassedCourses, Classified
    WHERE PassedCourses.course = Classified.code AND Classified.classification LIKE 'research'
    GROUP BY student;

CREATE VIEW AllMandatory AS --All mandatory courses from branch and program
    SELECT code FROM MandatoryProgram
    UNION 
    SELECT course FROM MandatoryBranch; 
    
CREATE VIEW Seminar AS --Passed couses of the classification "seminar"
SELECT course FROM PassedCourses
INTERSECT
SELECT code FROM Classified
WHERE classification = 'seminar';
-- sums all the students 

/*
--SELECT student, totalCredits, mandatoryLeft, mathCredits, researchCredits, seminarCourses, qualified FROM PathToGraduation ORDER BY student;
CREATE VIEW PathToGraduation AS 
    SELECT 1,
    SUM(credits) FROM PassedCourses,
    COUNT(UnreadMandatory.course),
    CountMathCredits.sumCredits, 
    CountResearchCredits.sumCredits,
    CountSeminarCourses.sumCourses,
        mandatoryLeft == NULL
        AND seminarCourses > 0 
        AND totalCredits >=10 
        AND mathCredits >= 20 
        AND researchCredits >= 10 
        AND seminarCourses
    IS NULL THEN "False" ELSE "True"
    END
    FROM Taken, Courses
    WHERE student = Taken.student AND taken.course = code AND student.idnr = taken.student AND Classified.course = code; */