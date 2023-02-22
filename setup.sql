--TABLES TABLES TABLES 
 CREATE TABLE Departments(
    departmentName TEXT NOT NULL, --Dep1
    departmentAbbrivation TEXT NOT NULL,    --D1
    PRIMARY KEY (departmentName ),       
    UNIQUE(departmentName, departmentAbbrivation) --Exists only one departAbbr per department
);


CREATE TABLE Programs(
    programName TEXT NOT NULL, --Prog1
    programAbbrivation TEXT NOT NULL,   --p1
    department TEXT NOT NULL,   --Dep1
    CONSTRAINT validDepartment FOREIGN KEY (department) REFERENCES Departments (departmentName),
    PRIMARY KEY (programName),
    UNIQUE (programName, programAbbrivation) --Exists only one programAbbr per prog
);

CREATE TABLE Students(
    idnr    TEXT PRIMARY KEY NOT NULL CONSTRAINT name_ten_char_long CHECK (char_length(idnr) = 10),
    name    TEXT NOT NULL,
    login   TEXT NOT NULL,
    program TEXT NOT NULL,
    CONSTRAINT validProgram FOREIGN KEY (program) REFERENCES Programs (programName), 
    UNIQUE(login)
);

    
CREATE TABLE Branches(
    name     TEXT NOT NULL CHECK(name in ('B1', 'B2')),
    program TEXT NOT NULL,
    PRIMARY KEY (name, program)
);


CREATE TABLE Courses(
    code CHAR(6) PRIMARY KEY NOT NULL,
    courseName TEXT NOT NULL,
    credits FLOAT(4) NOT NULL CONSTRAINT not_negative CHECK ( credits > 0),
    department TEXT NOT NULL,
    CONSTRAINT validDepartment FOREIGN KEY (department) REFERENCES Departments (departmentName), --See department
    UNIQUE (courseName, department)
);



CREATE TABLE LimitedCourses(
    code CHAR(6) PRIMARY KEY,
    capacity INT NOT NULL CONSTRAINT not_negative CHECK( capacity > 0),
    FOREIGN KEY (code) REFERENCES Courses(code)
);
    

CREATE TABLE StudentBranches(
    student TEXT PRIMARY KEY NOT NULL,
    branch TEXT NOT NULL,
    program TEXT NOT NULL,
    FOREIGN KEY (student) REFERENCES Students (idnr),
    FOREIGN KEY (branch, program) REFERENCES Branches (name, program),
    CONSTRAINT validBranch FOREIGN KEY (branch, program) REFERENCES Branches (name, program) --See branch belongs to correct program

);


CREATE TABLE Classifications(
      name TEXT PRIMARY KEY NOT NULL,
        CHECK (name IN ('math', 'research', 'seminar'))
);


CREATE TABLE Classified(
    code CHAR(6),
    classification TEXT,
    FOREIGN KEY (code) REFERENCES Courses (code),
    FOREIGN KEY (classification) REFERENCES Classifications (name),
    PRIMARY KEY(code, classification)
);


CREATE TABLE MandatoryProgram(
    code CHAR(6),      
    program TEXT NOT NULL,
    PRIMARY KEY(code, program),
    FOREIGN KEY (code) REFERENCES Courses (code)
);


CREATE TABLE MandatoryBranch(
    course CHAR(6),
    branch TEXT,
    program TEXT,
    PRIMARY KEY (course, branch, program),
    FOREIGN KEY (course) REFERENCES Courses (code),
    FOREIGN KEY (branch, program) REFERENCES Branches (name, program),
    UNIQUE(course, branch)

);



CREATE TABLE RecommendedBranch(
    courseCode CHAR(6),
    branch TEXT,
    program TEXT,
    PRIMARY KEY (courseCode, branch, program),
    FOREIGN KEY (courseCode) REFERENCES Courses (code),
    FOREIGN KEY (branch, program) REFERENCES Branches (name, program),
    UNIQUE(courseCode, program)

);


CREATE TABLE Registered(
    student TEXT,
    course CHAR(6),
    PRIMARY KEY (student, course),
    FOREIGN KEY (student) REFERENCES Students (idnr),
    FOREIGN KEY (course) REFERENCES Courses (code)
);


CREATE TABLE Taken(
    student TEXT,
    course CHAR(6),
    grade TEXT NOT NULL CHECK (grade IN ('U','3','4','5')),
    PRIMARY KEY (student,course),
    FOREIGN KEY (student) REFERENCES Students (idnr),
    FOREIGN KEY (course) REFERENCES Courses (code)
);


CREATE TABLE WaitingList(
    student TEXT,
    course CHAR(6),
    position INT NOT NULL,
    PRIMARY KEY(student,course),
    FOREIGN KEY (student) REFERENCES Students (idnr),
    FOREIGN KEY (course) REFERENCES LimitedCourses (code),
    UNIQUE(course, position)
    );



--VIEWS VIEWS VIEWS


--SELECT idnr, name, login, program, branch FROM BasicInformation ORDER BY idnr;
CREATE VIEW BasicInformation AS
    SELECT  idnr, Students.name, login, Students.program, COALESCE(branch,(Null)) as branch
    FROM    Students
    LEFT OUTER JOIN StudentBranches ON Students.idnr = StudentBranches.student;


--SELECT student, course, grade, credits FROM FinishedCourses ORDER BY student;
CREATE VIEW FinishedCourses AS
    SELECT  student, course, grade, Courses.credits as credits   
    FROM    Taken, Students, Courses
    Where   student = Students.idnr 
            AND course = Courses.code  
            AND credits = Courses.credits;


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
    SELECT MandatoryProgram.code, MandatoryProgram.program
    FROM MandatoryProgram
    UNION 
    SELECT MandatoryBranch.course, MandatoryBranch.program
    FROM MandatoryBranch;

--SELECT student, course FROM UnreadMandatory ORDER BY student;

CREATE VIEW UnreadMandatory AS
    SELECT BasicInformation.idnr as student, MandatoryProgram.code as course
    FROM BasicInformation, MandatoryProgram
    WHERE       MandatoryProgram.program = BasicInformation.program 
            AND BasicInformation.idnr 
            NOT IN (SELECT PassedCourses.student FROM PassedCourses where PassedCourses.course = MandatoryProgram.code)
    
    UNION

    SELECT BasicInformation.idnr as student, MandatoryBranch.course as course
    FROM BasicInformation, MandatoryBranch 
    WHERE       MandatoryBranch.branch = BasicInformation.branch 
            AND MandatoryBranch.program = BasicInformation.program
            AND BasicInformation.idnr 
            NOT IN (SELECT PassedCourses.student FROM PassedCourses where PassedCourses.course = MandatoryBranch.course);


CREATE VIEW PathToGraduation AS 
WITH
MathCredits AS(
    SELECT student, SUM(PassedCourses.credits) AS sumCreditsMath  
    FROM PassedCourses, Classified
    WHERE PassedCourses.course = Classified.code AND Classified.classification LIKE 'math'
    GROUP BY student),


ResearchCredits AS(
    SELECT student, SUM(PassedCourses.credits) AS sumCreditsRe  
    FROM PassedCourses, Classified
    WHERE PassedCourses.course = Classified.code AND Classified.classification LIKE 'research'
    GROUP BY student),


 SeminarCourses AS(
    SELECT student, COUNT(PassedCourses.course) AS sumSeminars
    FROM PassedCourses, Classified
    WHERE PassedCourses.course = Classified.code AND Classified.classification LIKE 'seminar'
    GROUP BY student),


sumBranchRecCred AS(
    SELECT student, SUM(PassedCourses.credits) AS sumRecBranch
    FROM PassedCourses, RecommendedBranch, BasicInformation
    WHERE       PassedCourses.course = RecommendedBranch.courseCode
            AND PassedCourses.student = BasicInformation.idnr
            AND BasicInformation.program = RecommendedBranch.program
            AND BasicInformation.branch = RecommendedBranch.branch
    GROUP BY student),


unreadMandatoryleft AS(
    SELECT student, COUNT(course) AS mandatoryLeft
      FROM UnreadMandatory
      GROUP BY student),


TotalCredits AS(
    SELECT student, SUM(credits) AS sumCreditsTot
    FROM PassedCourses
    GROUP BY student)


SELECT Students.idnr AS student,
    COALESCE (sumCreditsTot, 0) AS totalCredits,

   --COALESCE (sumRecBranch, 0) AS sumBranchRecCred,
    
    COALESCE (mandatoryLeft,0) AS mandatoryLeft, 
    COALESCE (sumCreditsMath, 0) AS mathCredits,
    COALESCE (sumCreditsRe, 0) AS researchCredits,
    COALESCE (sumSeminars, 0) AS seminarCourses,
    CASE 
        WHEN     COALESCE(sumSeminars,0) > 0 
            AND  COALESCE(mandatoryLeft, 0) = 0   
            AND  COALESCE(sumRecBranch, 0) >= 10
            AND  COALESCE(sumCreditsTot,0) >=10 
            AND  COALESCE(sumCreditsMath,0) >= 20 
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
    sumBranchRecCred
     ON idnr = sumBranchRecCred.student

    FULL OUTER JOIN 
    mathCredits
    ON idnr = MathCredits.student

    FULL OUTER JOIN 
      ResearchCredits
    ON idnr = ResearchCredits.student   

    FULL OUTER JOIN 
        unreadMandatoryleft
    ON idnr = unreadMandatoryleft.student;
















-- INSERT INSERT INSERT

INSERT INTO Branches VALUES ('B1','Prog1');
INSERT INTO Branches VALUES ('B2','Prog1');
INSERT INTO Branches VALUES ('B1','Prog2');

INSERT INTO Departments VALUES('Dep1', 'D1'); --new
INSERT INTO Departments VALUES('Dep2', 'D2'); --new

INSERT INTO Programs VALUES('Prog1', 'p1', 'Dep1');  --new
INSERT INTO Programs VALUES('Prog2', 'p2', 'Dep2');  --new

INSERT INTO Students VALUES ('1111111111','N1','ls1','Prog1');
INSERT INTO Students VALUES ('2222222222','N2','ls2','Prog1');
INSERT INTO Students VALUES ('3333333333','N3','ls3','Prog2');
INSERT INTO Students VALUES ('4444444444','N4','ls4','Prog1');
INSERT INTO Students VALUES ('5555555555','Nx','ls5','Prog2');
INSERT INTO Students VALUES ('6666666666','Nx','ls6','Prog2');
INSERT INTO Courses VALUES ('CCC111','C1',22.5,'Dep1');
INSERT INTO Courses VALUES ('CCC222','C2',20,'Dep1');
INSERT INTO Courses VALUES ('CCC333','C3',30,'Dep1');
INSERT INTO Courses VALUES ('CCC444','C4',60,'Dep1');
INSERT INTO Courses VALUES ('CCC555','C5',50,'Dep1');
INSERT INTO LimitedCourses VALUES ('CCC222',1);
INSERT INTO LimitedCourses VALUES ('CCC333',2);
INSERT INTO Classifications VALUES ('math');
INSERT INTO Classifications VALUES ('research');
INSERT INTO Classifications VALUES ('seminar');
INSERT INTO Classified VALUES ('CCC333','math');
INSERT INTO Classified VALUES ('CCC444','math');
INSERT INTO Classified VALUES ('CCC444','research');
INSERT INTO Classified VALUES ('CCC444','seminar');
INSERT INTO StudentBranches VALUES ('2222222222','B1','Prog1');
INSERT INTO StudentBranches VALUES ('3333333333','B1','Prog2');
INSERT INTO StudentBranches VALUES ('4444444444','B1','Prog1');
INSERT INTO StudentBranches VALUES ('5555555555','B1','Prog2');
INSERT INTO MandatoryProgram VALUES ('CCC111','Prog1');
INSERT INTO MandatoryBranch VALUES ('CCC333', 'B1', 'Prog1');
INSERT INTO MandatoryBranch VALUES ('CCC444', 'B1', 'Prog2');
INSERT INTO RecommendedBranch VALUES ('CCC222', 'B1', 'Prog1');
INSERT INTO RecommendedBranch VALUES ('CCC333', 'B1', 'Prog2');
INSERT INTO Registered VALUES ('1111111111','CCC111');
INSERT INTO Registered VALUES ('1111111111','CCC222');
INSERT INTO Registered VALUES ('1111111111','CCC333');
INSERT INTO Registered VALUES ('2222222222','CCC222');
INSERT INTO Registered VALUES ('5555555555','CCC222');
INSERT INTO Registered VALUES ('5555555555','CCC333');
INSERT INTO Registered VALUES ('6666666666','CCC333');
INSERT INTO Taken VALUES('4444444444','CCC111','5');
INSERT INTO Taken VALUES('4444444444','CCC222','5');
INSERT INTO Taken VALUES('4444444444','CCC333','5');
INSERT INTO Taken VALUES('4444444444','CCC444','5');
INSERT INTO Taken VALUES('5555555555','CCC111','5');
INSERT INTO Taken VALUES('5555555555','CCC222','4');
INSERT INTO Taken VALUES('5555555555','CCC444','3');
INSERT INTO Taken VALUES('2222222222','CCC111','U');
INSERT INTO Taken VALUES('2222222222','CCC222','U');
INSERT INTO Taken VALUES('2222222222','CCC444','U');

INSERT INTO WaitingList VALUES('2222222222','CCC222',1);
INSERT INTO WaitingList VALUES('3333333333','CCC222',2);

INSERT INTO WaitingList VALUES('3333333333','CCC333',1);





--SELECT student, totalCredits, mandatoryLeft, mathCredits, researchCredits, seminarCourses, qualified FROM PathToGraduation ORDER BY student;


/*

CREATE FUNCTION testONe() RETURNS TRIGGER AS   
$$
    DECLARE countPositions INT;
    BEGIN
            SELECT COUNT(*) INTO countPositions
            FROM CourseQueuePositions
            WHERE course = NEW.course;
        IF (NEW.position = countPositions) THEN
            RETURN NEW;
        ELSE 
            RAISE EXCEPTION 'bro what are you doing?';
        END IF;
    END  
$$ LANGUAGE plpgsql;
    

CREATE FUNCTION compact() RETURNS TRIGGER AS 
$$
    BEGIN  
        UPDATE WaitingList set position = position - 1
        WHERE course = old.course and position > OLD.position;
        RETURN OLD;
    END
$$LANGUAGE plpgsql;


CREATE TRIGGER duplicate_queue
    AFTER INSERT ON WaitingList
    FOR EACH ROW 
    EXECUTE FUNCTION testONe();
*/