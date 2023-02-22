

-- TEST #1: Register for an unlimited course.
-- EXPECTED OUTCOME: Pass
SELECT * FROM CourseQueuePositions;
INSERT INTO Registrations VALUES('6666666666','CCC222');
SELECT * FROM CourseQueuePositions;
