CREATE TABLE Students(
    idnr    TEXT(10) PRIMARY KEY NOT NULL,
    name    TEXT(2) NOT NULL,
    login   TEXT(3) NOT NULL,
    program TEXT(5) NOT NULL
);

CREATE TABLE Branches(
    name    TEXT(2) NOT NULL,
    program TEXT(5) NOT NULL,
    PRIMARY KEY (name, program)
);

CREATE TABLE Courses(
    code    PRIMARY KEY VARCHAR(6) NOT NULL,
    name    TEXT(2) NOT NULL,
    credits TEXT(3) NOT NULL,
    department  TEXT(5) NOT NULL,
    
);

CREATE TABLE LimitedCourses(
    capacity TINYINT(150) NOT NULL,
    PRIMARY KEY FOREIGN KEY (code) REFERENCES Courses(code)
);
    
CREATE TABLE StudentBranches(
    FOREIGN KEY (student) REFERENCES Students (idnr),
    branch VARCHAR(2) NOT NULL,
    program TEXT(5) NOT NULL,
    FOREIGN KEY (branch, program) REFERENCES Branches (branch, program)
);

CREATE TABLE Classifications(
      name TEXT(2) PRIMARY KEY NOT NULL
);

CREATE TABLE Classified(
    FOREIGN KEY (course) REFERENCES Courses (course),
    FOREIGN KEY (classification) REFERENCES Classifications (name)
    PRIMARY KEY(course, classification)
);

CREATE TABLE MandatoryProgram(
    PRIMARY KEY program TEXT(5) NOT NULL,
    FOREIGN KEY (code) REFERENCES Courses (code)
);


CREATE TABLE MandatoryBranch(
    course VARCHAR(6),
    branch TEXT,
    program TEXT(5),
    PRIMARY KEY (course, branch, program),
    FOREIGN KEY (course) REFERENCES Courses (code),
    FOREIGN KEY (branch, program) REFERENCES Branches (name, program),
);

CREATE TABLE RecommendedBranch(
    course VARCHAR(6),
    branch TEXT,
    program TEXT(5),
    PRIMARY KEY (course, branch, program),
    FOREIGN KEY (course) REFERENCES Courses (code),
    FOREIGN KEY (branch, program) REFERENCES Branches (name, program),
);

CREATE TABLE Registered(
    student TEXT,
    course VARCHAR(6),
    PRIMARY KEY (student, course),
    FOREIGN KEY (student) REFERENCES Students (idnr),
    FOREIGN KEY (course) REFERENCES Courses (code),
);

CREATE TABLE Taken(
    student TEXT,
    course VARCHAR(6),
    grade INT(1) NOT NULL,
    PRIMARY KEY (student,course),
    FOREIGN KEY (student) REFERENCES Students (idnr),
    FOREIGN KEY (course) REFERENCES Courses (code),
);

CREATE TABLE WaitingList(
    student TEXT,
    course VARCHAR(6),
    position INT (1) NOT NULL,
    PRIMARY KEY(student,course),
    FOREIGN KEY (student) REFERENCES Students (idnr),
    FOREIGN KEY (course) REFERENCES LimitedCourses (code)

);