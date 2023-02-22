

-- TEST #1: Register for an unlimited course.
-- EXPECTED OUTCOME: Pass
INSERT INTO Registrations VALUES('6666666666','CCC222');



-- TEST #2: Trying to register to a course the student is already registered to.
-- EXPECTED OUTCOME: Fail
INSERT INTO Registered VALUES ('6666666666','CCC111');
