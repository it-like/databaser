--SELECT idnr, name, login, program, branch FROM BasicInformation ORDER BY idnr;
CREATE VIEW BasicInformation AS
    SELECT idnr, Students.name, login, Students.program, COALESCE(branch,(Null)) as branch
    FROM Students
    LEFT OUTER JOIN StudentBranches ON Students.idnr = StudentBranches.student;


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


CREATE VIEW MandatoryCourses AS
    SELECT MandatoryProgram.course, MandatoryProgram.program
    FROM MandatoryProgram
    UNION 
    SELECT MandatoryBranch.course, MandatoryBranch.program
    FROM MandatoryBranch;


CREATE VIEW UnreadMandatoryCourses AS 
    --map mandatory course from program and branch to the 
    --specific student then see if it has passed that mandatory course:

    -- for student.program.mandatory.course not in passed 
    -- add a row
    -- for student.branch.mandatory.course not in passed
    -- add a row
    -- if no rows -> 0
    -- else: -> amount of rows



create view CountMathCredits AS
    SELECT student, SUM(PassedCourses.credits) AS sumCredits  
    FROM PassedCourses, Classified
    WHERE PassedCourses.course = Classified.course AND Classified.classification LIKE 'math'
    GROUP BY student;


CREATE VIEW CountResearchCredits AS
    SELECT student, SUM(PassedCourses.credits) AS sumCreditsRe  
    FROM PassedCourses, Classified
    WHERE PassedCourses.course = Classified.course AND Classified.classification LIKE 'research'
    GROUP BY student;

CREATE VIEW AllMandatory AS -- All mandatory courses from branch and 
    SELECT course FROM MandatoryProgram
    UNION 
    SELECT course FROM MandatoryBranch; 
    

CREATE VIEW CountSeminarCourses AS
    SELECT student, COUNT(PassedCourses.course) AS sumSeminars
    FROM PassedCourses, Classified
    WHERE PassedCourses.course = Classified.course AND Classified.classification LIKE 'seminar'
    GROUP BY student;



CREATE VIEW RecommendedCredits AS
    SELECT student, SUM(PassedCourses.credits) AS sumCreditsRec
    FROM PassedCourses, RecommendedBranch
    WHERE PassedCourses.course = RecommendedBranch.course
    GROUP BY student;




CREATE VIEW TotalCredits AS
    SELECT student, SUM(PassedCourses.credits) AS sumCreditsTot
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
            --AND  RecommendedCredits.sumCreditsRec >= 10
            AND  totalCredits >=10 
            AND  mathCredits >= 70 
            AND  researchCredits >= 10 
    THEN true 
    ELSE false
    END AS qualified
    FROM
    Students

    FULL OUTER JOIN (
        SELECT student, sum(sumCreditsRec)  AS recommendedCredits
        FROM RecommendedCredits
        GROUP BY student
    )

    RecommendedCredits
    ON idnr = RecommendedCredits.student
     
    FULL OUTER JOIN (
      SELECT student, SUM(PassedCourses.credits) AS totalCredits
      FROM PassedCourses
      GROUP BY student
    ) 
    totalCredits
     ON idnr = TotalCredits.student

<<<<<<< Updated upstream

=======
>>>>>>> Stashed changes
     FULL OUTER JOIN (
      SELECT student, COUNT(course) AS mandatoryLeft
      FROM UnreadMandatoryCourses
      GROUP BY student
    ) unreadMandatory
     ON idnr = UnreadMandatory.student

    FULL OUTER JOIN (
      SELECT student, COUNT(credits) AS seminarCourses
      FROM PassedCourses, Classified
      WHERE PassedCourses.course = Classified.course AND classification LIKE 'seminar'
      GROUP BY student
    )
    passedCourses
     ON idnr = PassedCourses.student


    FULL OUTER JOIN (
      SELECT student, SUM(credits) AS mathCredits
      FROM PassedCourses, Classified
      WHERE PassedCourses.course = Classified.course AND classification LIKE 'math'
      GROUP BY student

    ) 
    mathCredits
    ON idnr = MathCredits.student

    FULL OUTER JOIN (
      SELECT student, SUM(credits) AS researchCredits
      FROM PassedCourses, Classified
      where PassedCourses.course = Classified.course AND classification LIKE 'research'
      GROUP BY student
    ) 
    countResearchCredits
    ON idnr = CountResearchCredits.student;      