-- TEST #1: registered to an unlimited course
-- EXPECTED OUTCOME: Pass
INSERT INTO Registrations VALUES ('9999999999', 'CCC111'); 

-- TEST #2: Register an already registered student
-- EXPECTED OUTCOME: Fail
--INSERT INTO Registered VALUES ('9999999999','CCC111');

-- TEST #3: Registered to a limited course
-- EXPECTED OUTCOME: Pass
INSERT INTO Registrations VALUES('9999999999', 'CCC222');

-- TEST #4: Waiting for a limited course
-- EXPECTED OUTCOME: Pass
INSERT INTO Registrations VALUES('9999999999', 'CCC333');

-- TEST #5: removed from a waiting list (with additional students in it
-- EXPECTED OUTCOME: Pass
DELETE FROM Registrations WHERE student = '9999999999' AND course = 'CCC333';

-- TEST #6: unregistered from a limited course with a waiting list, when the student is registered;
-- EXPECTED OUTCOME: Pass
DELETE FROM Registrations WHERE student = '1111111111' AND course = 'CCC333';

-- TEST #7: unregistered from a limited course without a waiting list;
-- EXPECTED OUTCOME: Pass
DELETE FROM Registrations WHERE student = '9999999999' AND course = 'CCC222';

-- TEST #8: unregistered from a limited course with a waiting list, when the student is in the middle of the waiting list;
-- EXPECTED OUTCOME: Pass
DELETE FROM Registrations WHERE student = '8888888888' AND course = 'CCC333';

-- TEST #9: unregistered from an overfull course with a waiting list.
-- EXPECTED OUTCOME: Pass
DELETE FROM Registrations WHERE Student = '2222222222' AND course = 'CCC666';

--TEST #10: resgiter to a course with met prerequisites 
--EXPECTED OUTCOME : Pass
INSERT INTO Registrations VALUES('4444444444','CCC777');

--TEST #11: register to a course with unmet prerequisites
--EXPECTED OUTCOME : fail
--INSERT INTO Registrations VALUES('7777777777','CCC777');

--TEST #12: register to a course that has not been taken 
--EXPRECTED OUTCOME: pass
INSERT INTO Registrations VALUES ('9999999999', 'CCC444');

--TEST #13: register to a course that has already been taken
-- EXPECTED OUTCOME : fail
INSERT INTO Registrations VALUES('4444444444', 'CCC333');
