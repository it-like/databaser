CREATE VIEW CourseQueuePositions AS 
    SELECT course, student, position as place
    FROM WaitingList;    


CREATE OR REPLACE FUNCTION CheckCapacity()
RETURNS TRIGGER AS $$
    DECLARE studentsRegisteredOnCourse INT; -- Contains the current length of the waitinglist queue.
    DECLARE getQueuePosition INT;
    BEGIN   
           
        IF EXISTS (SELECT course FROM Registered where course = NEW.course AND student = NEW.student)
            THEN RAISE EXCEPTION 'Student % is already registered on course %', NEW.student, NEW.course;    -- Covered in pkey constraint
        END IF;

        IF ((SELECT grade FROM  Taken, Courses WHERE course = code AND 
            course = NEW.course AND Taken.student = NEW.student)
                 IN ('3','4','5'))                                                                          -- Have not passed course
                        THEN RAISE EXCEPTION 'Student % has already passed %', NEW.student, NEW.course; 
        END IF;
        
        studentsRegisteredOnCourse := (SELECT COUNT(*) FROM Registered WHERE course=NEW.course); 
        IF  (studentsRegisteredOnCourse) = (SELECT capacity FROM LimitedCourses WHERE code=NEW.course)                     -- If Capacity reached
            THEN    
                getQueuePosition := (SELECT COUNT(*) FROM WaitingList WHERE course = NEW.course);                                                                   
                RAISE NOTICE 'Capacity reached, placing on student % on waiting list position % for course %',
                 NEW.student, studentsRegisteredOnCourse, NEW.course;                   
                INSERT INTO WaitingList VALUES(NEW.student,NEW.course, (getQueuePosition + 1));                  -- Put on waiting list
            ELSE 
                INSERT INTO registered VALUES(NEW.student, NEW.course );                                    -- Register student on course
        END IF;
        RETURN NEW; 
    END $$
LANGUAGE PLPGSQL;


CREATE OR REPLACE FUNCTION removefromqueue()
RETURNS TRIGGER AS $$
    DECLARE studentsRegisteredOnCourse INT; -- Contains the current length of the waitinglist queue.
    DECLARE firstinqstudent TEXT;
    BEGIN   
            -- also check that it is not already registered
        studentsRegisteredOnCourse := (SELECT COUNT(*) FROM Registered WHERE course=OLD.course); 
        IF  (studentsRegisteredOnCourse) = (SELECT capacity FROM LimitedCourses WHERE code=OLD.course) 
            THEN
                RAISE NOTICE 'Removing student % and decrementing positions', OLD.student;
                firstinqstudent := (SELECT student FROM WaitingList WHERE course = OLD.course AND position = 1); --idnr for position 1

                RAISE NOTICE 'Removing student % from course %.', OLD.student, OLD.course;
                DELETE FROM Registered WHERE student = OLD.student and course = OLD.course;

                RAISE NOTICE 'Adding student % to course %', firstinqstudent, OLD.course;
                INSERT INTO registered VALUES (firstinqstudent, OLD.course);
                --if waitinglist != 0
                RAISE NOTICE 'Removing student % from course %.', OLD.student, OLD.course;
                DELETE FROM WaitingList WHERE (course = OLD.course AND position = 1);

                RAISE NOTICE 'Updating the position for all students';
                UPDATE WaitingList SET position = position - 1 WHERE course = OLD.course;
            -- remove student from waitinglist position 1 and add that student to registered. decrement all 
            -- other waiting students queue position by 1
        END IF;
        IF (studentsRegisteredOnCourse) > (SELECT capacity FROM LimitedCourses WHERE code=OLD.course) 
            THEN    
                RAISE NOTICE 'The course is overbooked, only removing student % from course %.', OLD.student, OLD.course;
                DELETE FROM Registered WHERE student = OLD.student and course = OLD.course;
        END IF;
        RETURN OLD; 
    END $$
LANGUAGE PLPGSQL;



CREATE TRIGGER trigger1
    INSTEAD OF INSERT OR UPDATE ON Registrations  
    FOR EACH ROW EXECUTE PROCEDURE 
    CheckCapacity();


CREATE TRIGGER trigger2
    INSTEAD OF DELETE ON Registrations
    FOR EACH ROW EXECUTE PROCEDURE
    removefromqueue();

