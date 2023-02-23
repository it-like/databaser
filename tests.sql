
INSERT INTO Registered VALUES ('1111111111','CCC111');


-- TEST #3: registered to a limited course
-- EXPECTED OUTCOME: Pass
INSERT INTO Registered VALUES('7777777777', 'CCC222');

-- TEST #4: waiting for a limited course
-- EXPECTED OUTCOME: Pass

INSERT INTO WaitingList VALUES('8888888888', 'CCC222', 3)

-- TEST #5: removed from a waiting list (with additional students in it
-- EXPECTED OUTCOME: Pass

DELETE FROM WaitingList WHERE student = '8888888888';

-- TEST #6: unregistered from a limited course without a waiting list;
-- EXPECTED OUTCOME: Pass


-- TEST #7: unregistered from a limited course with a waiting list, when the student is registered;
-- EXPECTED OUTCOME: Pass

--

-- TEST #8: unregistered from a limited course with a waiting list, when the student is in the middle of the waiting list;
-- EXPECTED OUTCOME: 
--

-- TEST #9: unregistered from an overfull course with a waiting list.
-- EXPECTED OUTCOME: 

