

-- TEST #1: Register for an unlimited course.
-- EXPECTED OUTCOME: Pass
SELECT * FROM CourseQueuePositions;
INSERT INTO Registrations VALUES('4444444444','CCC222');
SELECT * FROM CourseQueuePositions;
