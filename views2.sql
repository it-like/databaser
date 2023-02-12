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
    FROM PassedCourses, MandatoryProgram
    WHERE MandatoryProgram.code != PassedCourses.course;

create view CountMathCredits AS
    SELECT student, SUM(PassedCourses.credits) AS sumCredits  
    FROM PassedCourses, Classified
    WHERE PassedCourses.course = Classified.code AND Classified.classification LIKE 'math'
    GROUP BY student;


CREATE VIEW CountResearchCredits AS
    SELECT student, SUM(PassedCourses.credits) AS sumCreditsRe  
    FROM PassedCourses, Classified
    WHERE PassedCourses.course = Classified.code AND Classified.classification LIKE 'research'
    GROUP BY student;

CREATE VIEW AllMandatory AS -- All mandatory courses from branch and 
    SELECT code FROM MandatoryProgram
    UNION 
    SELECT course FROM MandatoryBranch; 
    

CREATE VIEW CountSeminarCourses AS
    SELECT student, COUNT(PassedCourses.course) AS sumSeminars
    FROM PassedCourses, Classified
    WHERE PassedCourses.course = Classified.code AND Classified.classification LIKE 'seminar'
    GROUP BY student;



CREATE VIEW RecommendedCredits AS
    SELECT student, SUM(PassedCourses.credits) AS credits
    FROM PassedCourses, RecommendedBranch
    WHERE PassedCourses.course = RecommendedBranch.course
    GROUP BY student;


--CREATE VIEW CountUnreadMandatory AS
    --SELECT student, COUNT(UnreadMandatory.course) AS amountOfMandatoryLeft
   -- FROM UnreadMandatory
 --   GROUP BY student;

CREATE VIEW TotalCredits AS
    SELECT student, sum(PassedCourses.credits) AS credits
    FROM PassedCourses
    GROUP BY student;


--SELECT student, totalCredits, mandatoryLeft, mathCredits, researchCredits, seminarCourses, qualified FROM PathToGraduation ORDER BY student;
CREATE VIEW PathToGraduation AS 
    SELECT Students.idnr AS student,
    COALESCE (totalCredits,(0)) AS totalCredits,
    COALESCE (mandatoryLeft,(0)) AS mandatoryLeft, 
    COALESCE (mathCredits,(0)) AS mathCredits,
    COALESCE (researchCredits, (0)) AS researchCredits,
    COALESCE (seminarCourses,(0)) AS seminarCourses,
    CASE 
        WHEN     seminarCourses > 0 
            AND  recommendedCredits >= 10
            AND  totalCredits >=10 
            AND  mathCredits >= 70 
            AND  researchCredits >= 10 
    THEN 'TRUE' 
    ELSE 'FALSE'
    END AS qualified
    FROM
    Students

    FULL OUTER JOIN (
      SELECT student, SUM(PassedCourses.credits) AS totalCredits
      FROM PassedCourses
      GROUP BY student
    ) 
    TotalCredits
    ON idnr = TotalCredits.student

    FULL OUTER JOIN (
        SELECT student, sum(credits)  AS recommendedCredits
        FROM RecommendedCredits
        GROUP BY student
    )
    RecommendedCredits
    ON idnr = RecommendedCredits.student

     FULL OUTER JOIN (
      SELECT student, COUNT(course) AS mandatoryLeft
      FROM UnreadMandatory
      GROUP BY student
    ) 
    unreadMandatory
    ON idnr = UnreadMandatory.student

    FULL OUTER JOIN (
      SELECT student, COUNT(credits) AS seminarCourses
      FROM PassedCourses, Classified
      WHERE course = code AND classification LIKE 'seminar'
      GROUP BY student
    )
    passedCourses
    ON idnr = PassedCourses.student


    FULL OUTER JOIN (
      SELECT student, SUM(credits) AS mathCredits
      FROM PassedCourses, Classified
      WHERE course = code AND classification LIKE 'math'
      GROUP BY student

    ) 
    mathCredits
    ON idnr = MathCredits.student

    FULL OUTER JOIN (
      SELECT student, SUM(credits) AS researchCredits
      FROM PassedCourses, Classified
      where course = code AND classification LIKE 'research'
      GROUP BY student
    ) 
    countResearchCredits
    ON idnr = CountResearchCredits.student;      