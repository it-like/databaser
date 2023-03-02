-- TEST #1: registered to an unlimited course
-- EXPECTED OUTCOME: Pass
--INSERT INTO Registrations VALUES ('7777777777', 'CCC333'); 
--INSERT INTO Registrations VALUES ('7777777777', 'CCC444'); 

-- TEST #2: Register an already registered student.
-- EXPECTED OUTCOME: Fail
INSERT INTO Registered VALUES ('1111111111','CCC111');

-- TEST #3: registered to a limited course
-- EXPECTED OUTCOME: Pass
INSERT INTO Registrations VALUES('9999999999', 'CCC222');

-- TEST #4: waiting for a limited course
-- EXPECTED OUTCOME: Pass
INSERT INTO Registrations VALUES('8888888888', 'CCC222');

-- TEST #5: removed from a waiting list (with additional students in it
-- EXPECTED OUTCOME: Pass
DELETE FROM Registrations WHERE student = '8888888888' AND course = 'CCC222';

-- TEST #6: unregistered from a limited course with a waiting list, when the student is registered;
-- EXPECTED OUTCOME: Pass
DELETE FROM Registrations WHERE student = '1111111111' AND course = 'CCC333';

-- TEST #7: unregistered from a limited course without a waiting list;
-- EXPECTED OUTCOME: Pass
DELETE FROM Registrations WHERE student = '5555555555' AND course = 'CCC333';

-- TEST #8: unregistered from a limited course with a waiting list, when the student is in the middle of the waiting list;
-- EXPECTED OUTCOME: Pass
DELETE FROM Registrations WHERE student = '3333333333' AND course = 'CCC222';

-- TEST #9: unregistered from an overfull course with a waiting list.
-- EXPECTED OUTCOME: Pass
DELETE FROM Registrations WHERE Student = '1111111111' AND course = 'CCC222';

--TEST #10: resgiter to an unlimited course with met prerequisites 
--EXPECTED OUTCOME : Pass
INSERT INTO Registrations VALUES('6666666666','CCC555');

--TEST #11: register to a course with unmet prerequisites
--EXPECTED OUTCOME : fail
INSERT INTO Registrations VALUES('2222222222','CCC555');
