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
    
CREATE VIEW MandatoryCourses AS
    SELECT MandatoryProgram.course, MandatoryProgram.program
    FROM MandatoryProgram
    UNION 
    SELECT MandatoryBranch.course, MandatoryBranch.program
    FROM MandatoryBranch;

--SELECT student, course FROM UnreadMandatory ORDER BY student;

CREATE VIEW UnreadMandatory AS
    SELECT BasicInformation.idnr as student, MandatoryProgram.course as course
    FROM BasicInformation, MandatoryProgram
    WHERE MandatoryProgram.program = BasicInformation.program 
    AND BasicInformation.idnr NOT IN (SELECT PassedCourses.student FROM PassedCourses where PassedCourses.course = MandatoryProgram.course)
    UNION
    SELECT BasicInformation.idnr as student, MandatoryBranch.course as course
    FROM BasicInformation, MandatoryBranch 
    WHERE       MandatoryBranch.branch = BasicInformation.branch AND MandatoryBranch.program = BasicInformation.program
            AND BasicInformation.idnr NOT IN (SELECT PassedCourses.student FROM PassedCourses where PassedCourses.course = MandatoryBranch.course);

--CREATE VIEW MandatoryLeft AS 
    



--SELECT student, totalCredits, mandatoryLeft, mathCredits, researchCredits, seminarCourses, qualified FROM PathToGraduation ORDER BY student;
CREATE VIEW PathToGraduation AS 
WITH
MathCredits AS(
    SELECT student, SUM(PassedCourses.credits) AS sumCreditsMath  
    FROM PassedCourses, Classified
    WHERE PassedCourses.course = Classified.course AND Classified.classification LIKE 'math'
    GROUP BY student),


ResearchCredits AS(
    SELECT student, SUM(PassedCourses.credits) AS sumCreditsRe  
    FROM PassedCourses, Classified
    WHERE PassedCourses.course = Classified.course AND Classified.classification LIKE 'research'
    GROUP BY student),

    

 SeminarCourses AS(
    SELECT student, COUNT(PassedCourses.course) AS sumSeminars
    FROM PassedCourses, Classified
    WHERE PassedCourses.course = Classified.course AND Classified.classification LIKE 'seminar'
    GROUP BY student),


RecommendedCredits AS(
    SELECT student, SUM(PassedCourses.credits) AS sumCreditsRec
    FROM PassedCourses, RecommendedBranch
    WHERE PassedCourses.course = RecommendedBranch.course AND 
    GROUP BY student),


MandatoryLe AS(
    SELECT student, COUNT(course) AS mandatoryLeft
      FROM UnreadMandatory
      GROUP BY student),

TotalCredits AS(
    SELECT student, SUM(credits) AS sumCreditsTot
    FROM PassedCourses
    GROUP BY student)

SELECT Students.idnr AS student,
    COALESCE (sumCreditsTot, 0) AS totalCredits,
    
    COALESCE (mandatoryLeft,0) AS mandatoryLeft, 
    COALESCE (sumCreditsMath, 0) AS mathCredits,
    COALESCE (sumCreditsRe, 0) AS researchCredits,
    COALESCE (sumSeminars, 0) AS seminarCourses,
    CASE 
        WHEN     COALESCE(sumSeminars,0) > 0 
            AND  COALESCE(mandatoryLeft, 0) = 0   
            AND  COALESCE(sumCreditsRec,0) >= 10
            AND  COALESCE(sumCreditsTot,0) >=10 
            AND  COALESCE(sumCreditsMath,0) >= 20 
            AND  COALESCE(sumCreditsRe,0) >= 10 
    THEN true 
    ELSE false
    END AS qualified
    FROM
    Students
     
    FULL OUTER JOIN 
    totalCredits ON idnr = TotalCredits.student

    FULL OUTER JOIN 
    seminarCourses
     ON idnr = seminarCourses.student

    FULL OUTER JOIN 
    RecommendedCredits
     ON idnr = RecommendedCredits.student

    FULL OUTER JOIN 
    mathCredits
    ON idnr = MathCredits.student

    FULL OUTER JOIN 
      ResearchCredits
    ON idnr = ResearchCredits.student   

    FULL OUTER JOIN 
        MandatoryLe
    ON idnr = mandatoryLe.student;