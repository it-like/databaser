CREATE TABLE Branches(
    name    TEXT
    program TEXT(5)
    PRIMARY KEY (name, program)
)

CREATE TABLE Students(
    idnr TEXT PRIMARY KEY
    name TEXT(2)
    credits TEXT(3)
    

)


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