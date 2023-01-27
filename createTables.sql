CREATE TABLE Students(
    idnr    CHAR(10) PRIMARY KEY NOT NULL,
    --CHECK (idnr LIKE '%[0-9]%{10}'),
    stuname CHAR(20) NOT NULL,
    stulog  TEXT UNIQUE NOT NULL,
    program CHAR(5) NOT NULL
);

CREATE TABLE Branches(
    branchName CHAR(20) NOT NULL,
    program CHAR(5) NOT NULL,
    PRIMARY KEY (branchName, program)
);

CREATE TABLE Courses(
    code    VARCHAR(6) PRIMARY KEY NOT NULL,
    stuname CHAR(2) NOT NULL,
    credits CHAR(3) NOT NULL,
    department  CHAR(5) NOT NULL    
);

CREATE TABLE LimitedCourses(
    code VARCHAR(6) PRIMARY KEY,
    capacity VARCHAR(150) NOT NULL,
    FOREIGN KEY(code) REFERENCES Courses (code)
);  

CREATE TABLE StudentBranches(
    student CHAR(10) PRIMARY KEY NOT NULL,
    FOREIGN KEY (student) REFERENCES Students (idnr),
    branch VARCHAR(2) NOT NULL,
    program CHAR(5) NOT NULL,
    FOREIGN KEY (branch, program) REFERENCES Branches (branchName, program)
);


CREATE TABLE Classifications(
    stuname TEXT PRIMARY KEY NOT NULL
);
    
CREATE TABLE Classified(
    course VARCHAR(6),
    classification TEXT,
    FOREIGN KEY (course) REFERENCES Courses (code),
    FOREIGN KEY (classification) REFERENCES Classifications (stuname),
    PRIMARY KEY(course, classification)
);

CREATE TABLE MandatoryProgram(
    course VARCHAR(6),
    program CHAR(5),   
    FOREIGN KEY (course) REFERENCES Courses
);

CREATE TABLE MandatoryBranch(
    course VARCHAR(6),
    branch TEXT,
    program CHAR(5),
    PRIMARY KEY (course, branch, program),
    FOREIGN KEY (course) REFERENCES Courses (code),
    FOREIGN KEY (branch, program) REFERENCES Branches (branchName, program)
);

CREATE TABLE RecommendedBranch(
    course VARCHAR(6),
    branch TEXT,
    program CHAR(5),
    PRIMARY KEY (course, branch, program),
    FOREIGN KEY (course) REFERENCES Courses (code),
    FOREIGN KEY (branch, program) REFERENCES Branches (branchName, program)
);  

CREATE TABLE Registered(
    student TEXT,
    course VARCHAR(6),
    PRIMARY KEY (student, course),
    FOREIGN KEY (student) REFERENCES Students (idnr),
    FOREIGN KEY (course) REFERENCES Courses (code)
);

CREATE TABLE Taken(
    student TEXT,
    course VARCHAR(6),
    grade CHAR(1) NOT NULL,
    PRIMARY KEY (student,course),
    FOREIGN KEY (student) REFERENCES Students (idnr),
    FOREIGN KEY (course) REFERENCES Courses (code)
);

CREATE TABLE WaitingList(
    student TEXT,
    course TEXT,
    position CHAR(1) NOT NULL,
    FOREIGN KEY (student) REFERENCES Students (idnr),
    FOREIGN KEY (course) REFERENCES LimitedCourses (code),
    PRIMARY KEY(student,course)
);