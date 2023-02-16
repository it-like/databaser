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
    FOREIGN KEY (branch, program) REFERENCES Branches (name, program)
);


CREATE TABLE Classifications(
      name TEXT PRIMARY KEY NOT NULL
);


CREATE TABLE Classified(
    course CHAR(6),
    classification TEXT,
    FOREIGN KEY (course) REFERENCES Courses (code),
    FOREIGN KEY (classification) REFERENCES Classifications (name),
    PRIMARY KEY(course, classification)
);


CREATE TABLE MandatoryProgram(
    course CHAR(6),      
    program TEXT NOT NULL,
    PRIMARY KEY(course, program),
    FOREIGN KEY (course) REFERENCES Courses (code)
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
    FOREIGN KEY (course) REFERENCES LimitedCourses (code)
);


