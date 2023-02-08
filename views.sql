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

create view CountMathCredits AS
    SELECT student, SUM(PassedCourses.credits) AS sumCredits   
    FROM PassedCourses, Classified
    WHERE PassedCourses.course = Classified.code AND Classified.classification LIKE 'math';
    --GROUP BY student;


CREATE VIEW CountResearchCredits AS
    SELECT student, SUM(PassedCourses.credits) AS sumCredits   
    FROM PassedCourses, Classified
    WHERE PassedCourses.course = Classified.code AND Classified.classification LIKE 'research';
   -- GROUP BY student;

CREATE VIEW AllMandatory AS -- All mandatory courses from branch and 
    SELECT code FROM MandatoryProgram
    UNION 
    SELECT course FROM MandatoryBranch ; 
    
CREATE VIEW CountSeminarCourses AS
    SELECT student, COUNT(PassedCourses.course) AS sumSeminars
    FROM PassedCourses, Classified
    WHERE PassedCourses.course = Classified.code AND Classified.classification LIKE 'seminar';
    --GROUP BY student;
-- sums all the students 


CREATE VIEW RecomendedCredits AS
    SELECT student, SUM(PassedCourses.credits) AS sumCredits
    FROM PassedCourses, RecommendedBranch
    WHERE PassedCourses.course = RecommendedBranch.course;
    --GROUP BY student;

CREATE VIEW TotalCredits AS
    SELECT student, SUM(PassedCourses.credits) AS sumCredits;
    FROM PassedCourses;
    --GROUP BY student;

--SELECT student, totalCredits, mandatoryLeft, mathCredits, researchCredits, seminarCourses, qualified FROM PathToGraduation ORDER BY student;
CREATE VIEW PathToGraduation AS 
    SELECT idnr,
    TotalCredits,
    UnreadMandatory.course ,
    CountMathCredits.sumCredits, 
    CountResearchCredits.sumCredits,
    CountSeminarCourses.sumSeminars,
    CASE 
        WHEN
            UnreadMandatory.course IS NULL
            --AND (SELECT AllMandatory EXCEPT PassedCourses.course IS NULL)
            AND RecomendedCredits.sumCredits >= 10
            AND TotalCredits.sumCredits >= 10 
            AND CountMathCredits.sumCredits >= 20 
            AND CountResearchCredits.sumCredits >= 10 
            AND CountSeminarCourses.sumSeminars > 0
    THEN TRUE 
    ELSE FALSE
    END as qualified
    FROM Students, TotalCredits, UnreadMandatory, CountMathCredits, CountResearchCredits, CountSeminarCourses, RecomendedCredits
    WHERE idnr = TotalCredits.student AND idnr = UnreadMandatory.student AND idnr = CountMathCredits.student
    GROUP BY idnr;