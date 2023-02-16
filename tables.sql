--CREATE TYPE grade_enum AS ENUM('3','4','5');
--SELECT * FROM grade_enum;
 --TESTING
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



-- All functions
);
CREATE OR REPLACE FUNCTION checkIfPassed()
RETURNS TRIGGER AS $$
    BEGIN 
        IF (SELECT NEW.grade) IN ('3','4','5') AND 
            EXISTS (SELECT course, student FROM Registered where New.course = Registered.course AND NEW.student =Registered.student)
        THEN 
            RAISE NOTICE 'The student % has already read and passed the course % with grade %', NEW.student, NEW.course , NEW.grade; -- notice as goes by
            DELETE FROM Registered WHERE course = NEW.course AND student = NEW.student; -- removes all faulty inputs

        END IF;
        RETURN NEW;
    END $$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION CheckCapacity()
RETURNS TRIGGER AS $$
    DECLARE valueToGive INT; -- Contains the current length of the waitinglist queue.
    BEGIN   
        IF (SELECT grade
                FROM  Taken, Courses
                WHERE course = code AND course = NEW.course AND Taken.student = NEW.student) IN ('3','4','5')
        THEN RAISE EXCEPTION 'Student % has already passed % with grade %', NEW.student, NEW.course, NEW.grade;    -- If inserted before taken 

        valueToGive := (SELECT COUNT(*) FROM Registered WHERE course=NEW.course);
        IF  (valueToGive) > (SELECT capacity FROM LimitedCourses WHERE code=NEW.course) 
            THEN
                INSERT INTO WaitingList VALUES(NEW.student,NEW.course, (valueToGive - 10));
        END IF;
        END IF;
        RETURN NEW;
    END $$
LANGUAGE PLPGSQL;

DROP TRIGGER IF EXISTS checkCapacity ON Registered;

CREATE TRIGGER checkCapacity
    BEFORE INSERT ON Registered
    FOR EACH ROW EXECUTE PROCEDURE CheckCapacity();


CREATE TRIGGER checkInTakenRemoveRegistered --if student has already taken a class (and passed) they should not be able to register to it again
    BEFORE INSERT ON Taken
    FOR EACH ROW EXECUTE PROCEDURE 
    checkIfPassed();
