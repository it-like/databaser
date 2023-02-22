CREATE VIEW CourseQueuePositions AS 
    SELECT course, student, position as place
    FROM WaitingList;    




CREATE OR REPLACE FUNCTION throwError()
RETURNS TRIGGER AS $$
BEGIN
    IF 1 == 1
    THEN
    RAISE EXCEPTION 'This is course number %' NEW.code;
    END IF;
END$$
LANGUAGE PLPGSQL;


DROP TRIGGER IF EXISTS checkCapacity ON Courses;

CREATE TRIGGER checkCapacity
    BEFORE INSERT OR UPDATE ON Courses  
    FOR EACH ROW EXECUTE PROCEDURE 
    throwErrors();


/*
--UNNECESSARY triggers xd
-- All functions
CREATE OR REPLACE FUNCTION checkIfPassed()
RETURNS TRIGGER AS $$
    BEGIN 
        IF (SELECT NEW.grade) IN ('3','4','5') AND 
            EXISTS (SELECT course, student FROM Registered where New.course = Registered.course AND NEW.student =Registered.student)
        THEN 
            RAISE EXCEPTION 'The student % has already read and passed the course % with grade %.', NEW.student, NEW.course , NEW.grade; -- notice as goes by
            DELETE FROM Registered WHERE course = NEW.course AND student = NEW.student; -- removes raise notice 
        END IF;
        RETURN NEW;
    END $$
LANGUAGE PLPGSQL;



CREATE OR REPLACE FUNCTION CheckCapacity()
RETURNS TRIGGER AS $$
    DECLARE valueToGive INT; -- Contains the current length of the waitinglist queue.
    BEGIN   
        IF (SELECT grade
                FROM  Taken, Courses
                WHERE course = code AND course = NEW.course AND Taken.student = NEW.student) IN ('3','4','5')
        THEN RAISE EXCEPTION 'Student % has already passed % with grade %', NEW.student, NEW.course, NEW.grade;    -- If inserted before taken 

        valueToGive := (SELECT COUNT(*) FROM Registered WHERE course=NEW.course);
        IF  (valueToGive) > (SELECT capacity FROM LimitedCourses WHERE code=NEW.course) 
            THEN
                INSERT INTO WaitingList VALUES(NEW.student,NEW.course, (valueToGive - 10));
        END IF;
        END IF;
        RETURN NEW; 
    END $$
LANGUAGE PLPGSQL;

DROP TRIGGER IF EXISTS checkCapacity ON Registrations;

CREATE TRIGGER checkCapacity
    BEFORE INSERT OR UPDATE ON Registered  
    FOR EACH ROW EXECUTE PROCEDURE 
    CheckCapacity();


CREATE TRIGGER checkInTakenRemoveRegistered --if student has already taken a class (and passed) they should not be able to register to it again
    BEFORE INSERT OR UPDATE ON Taken
    FOR EACH ROW EXECUTE PROCEDURE 
    checkIfPassed();
*/