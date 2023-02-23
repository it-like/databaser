SELECT * FROM CourseQueuePositions WHERE course = 'CCC222';


-- TEST #1: Register for an unlimited course.
-- EXPECTED OUTCOME: Pass
INSERT INTO Registrations VALUES('7777777777','CCC222');


-- TEST #2: Trying to register to a course the student is already registered to.
-- EXPECTED OUTCOME: Fail
--INSERT INTO Registered VALUES ('6666666666','CCC111');

SELECT * FROM CourseQueuePositions WHERE course = 'CCC222';
--
DELETE FROM Registrations WHERE student = '2222222222' and course = 'CCC222';

SELECT * FROM CourseQueuePositions WHERE course = 'CCC222';