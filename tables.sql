CREATE TABLE Students(
    idnr    TEXT PRIMARY KEY NOT NULL,
    name    TEXT NOT NULL,
    login   TEXT NOT NULL,
    program TEXT NOT NULL
);


CREATE TABLE Branches(
    name    TEXT NOT NULL,
    program TEXT NOT NULL,
    PRIMARY KEY (name, program)
);


CREATE TABLE Courses(
    code CHAR(6) PRIMARY KEY NOT NULL,
    name    TEXT NOT NULL,
    credits FLOAT(4) NOT NULL,
    department  TEXT NOT NULL
);


CREATE TABLE LimitedCourses(
    code CHAR(6) PRIMARY KEY,
    capacity CHAR NOT NULL,--vafan är TINYINT??
    FOREIGN KEY (code) REFERENCES Courses(code)
);
    

CREATE TABLE StudentBranches(
    student TEXT PRIMARY KEY NOT NULL,
    branch TEXT NOT NULL,
    program TEXT NOT NULL,
    FOREIGN KEY (student) REFERENCES Students (idnr),
    FOREIGN KEY (branch, program) REFERENCES Branches (name, program)
);


CREATE TABLE Classifications(
      name TEXT PRIMARY KEY NOT NULL
);


CREATE TABLE Classified(
    code CHAR(6),
    classification TEXT,
    FOREIGN KEY (code) REFERENCES Courses (code),
    FOREIGN KEY (classification) REFERENCES Classifications (name),
    PRIMARY KEY(code, classification)
);


CREATE TABLE MandatoryProgram(
    code CHAR(6),       --ska egentligen heta course men men
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
    FOREIGN KEY (branch, program) REFERENCES Branches (name, program)
);


CREATE TABLE RecommendedBranch(
    course CHAR(6),
    branch TEXT,
    program TEXT,
    PRIMARY KEY (course, branch, program),
    FOREIGN KEY (course) REFERENCES Courses (code),
    FOREIGN KEY (branch, program) REFERENCES Branches (name, program)
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
    grade TEXT
    CHECK  (NOT NULL AND grade IN ('U','3','4','5')),
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
    FOREIGN KEY (course) REFERENCES LimitedCourses (code)

);
