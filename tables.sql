CREATE TABLE Students(
    idnr    TEXT PRIMARY KEY NOT NULL,
    --CHECK (idnr LIKE '%[0-9]%{10}'),
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
    code VARCHAR(6) PRIMARY KEY NOT NULL,
    name    TEXT NOT NULL,
    credits TEXT NOT NULL,
    department  TEXT NOT NULL
);

CREATE TABLE LimitedCourses(
    code VARCHAR(6) UNIQUE,
    capacity CHAR NOT NULL,--vafan är TINYINT??
    FOREIGN KEY (code) REFERENCES Courses(code)
);
    
CREATE TABLE StudentBranches(
    student TEXT NOT NULL,
    branch TEXT NOT NULL,
    program TEXT NOT NULL,
    FOREIGN KEY (student) REFERENCES Students (idnr),
    FOREIGN KEY (branch, program) REFERENCES Branches (name, program)
);

CREATE TABLE Classifications(
      name TEXT PRIMARY KEY NOT NULL
);

CREATE TABLE Classified(
    course VARCHAR(6),
    classification TEXT,
    FOREIGN KEY (course) REFERENCES Courses (code),
    FOREIGN KEY (classification) REFERENCES Classifications (name),
    PRIMARY KEY(course, classification)
);

CREATE TABLE MandatoryProgram(
    code VARCHAR(6),
    program TEXT PRIMARY KEY NOT NULL,
    FOREIGN KEY (code) REFERENCES Courses (code)
);


CREATE TABLE MandatoryBranch(
    course VARCHAR(6),
    branch TEXT,
    program TEXT,
    PRIMARY KEY (course, branch, program),
    FOREIGN KEY (course) REFERENCES Courses (code),
    FOREIGN KEY (branch, program) REFERENCES Branches (name, program)
);

CREATE TABLE RecommendedBranch(
    course VARCHAR(6),
    branch TEXT,
    program TEXT,
    PRIMARY KEY (course, branch, program),
    FOREIGN KEY (course) REFERENCES Courses (code),
    FOREIGN KEY (branch, program) REFERENCES Branches (name, program)
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
    grade TEXT CHECK (NOT NULL AND grade IN ('U','3','4','5')),
    PRIMARY KEY (student,course),
    FOREIGN KEY (student) REFERENCES Students (idnr),
    FOREIGN KEY (course) REFERENCES Courses (code)
);

CREATE TABLE WaitingList(
    student TEXT,
    course VARCHAR(6),
    position INT NOT NULL,
    PRIMARY KEY(student,course),
    FOREIGN KEY (student) REFERENCES Students (idnr),
    FOREIGN KEY (course) REFERENCES LimitedCourses (code)

);

