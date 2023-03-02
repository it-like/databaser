CREATE VIEW CourseQueuePositions AS 
    SELECT course, student, position as place
    FROM WaitingList;    


CREATE OR REPLACE FUNCTION registration()
RETURNS TRIGGER AS $$
    DECLARE studentsRegisteredOnCourse INT; -- Contains the current length of the waitinglist queue.
    DECLARE getQueuePosition INT;
    BEGIN   
        IF EXISTS (SELECT code FROM PrerequisiteCourses WHERE code = NEW.course)
            THEN IF ((SELECT prerequisitecourse FROM PrerequisiteCourses where code = NEW.course) NOT IN (SELECT course FROM PassedCourses WHERE PassedCourses.student = NEW.student))
                     THEN RAISE EXCEPTION 'The student % have not met the prerequisites for this course', NEW.student;
            END IF;
        END IF;
        IF EXISTS (SELECT course FROM Registered where course = NEW.course AND student = NEW.student)
            THEN RAISE EXCEPTION 'Student % is already registered on course %', NEW.student, NEW.course;    -- Covered in pkey constraint
        END IF;
        IF ((SELECT grade FROM  Taken, Courses WHERE course = code AND 
            course = NEW.course AND Taken.student = NEW.student)
                 IN ('3','4','5'))                                                                          -- Have not passed course
                        THEN RAISE EXCEPTION 'Student % has already passed %', NEW.student, NEW.course; 
        END IF;
        
        studentsRegisteredOnCourse := (SELECT COUNT(*) FROM Registrations WHERE course=NEW.course and status = 'registered'); 
        IF  (studentsRegisteredOnCourse) >= (SELECT capacity FROM LimitedCourses WHERE code=NEW.course)                     -- If Capacity reached
            THEN    
                getQueuePosition := (SELECT COUNT(*) FROM WaitingList WHERE course = NEW.course);                                                                   
                RAISE NOTICE 'Capacity reached, placing student % on waiting list position % for course %',
                 NEW.student, getQueuePosition + 1, NEW.course;                   
                INSERT INTO WaitingList VALUES(NEW.student,NEW.course, (getQueuePosition + 1));   
            ELSE 
                RAISE NOTICE 'Student registered % to course %', NEW.student, NEW.course;   
                INSERT INTO registered VALUES(NEW.student, NEW.course );                                    -- Register student on course
        END IF;
        RETURN NEW; 
    END $$
LANGUAGE PLPGSQL;


CREATE OR REPLACE FUNCTION unregistration() 
RETURNS TRIGGER AS $$
    DECLARE studentsRegisteredOnCourse INT; -- Contains the current length of the waitinglist queue.
    DECLARE idnrForPosition1 TEXT;
    DECLARE countPeopleInWaitingList INT;
    DECLARE courseCapacity INT;
    DECLARE queuePosition INT;
    DECLARE inWaitingList BOOLEAN;
    BEGIN   

        studentsRegisteredOnCourse := (SELECT COUNT(*) FROM Registrations WHERE course=OLD.course AND status = 'registered'); 
        countPeopleInWaitingList := (SELECT COUNT(*) FROM WaitingList WHERE course = OLD.course);
        courseCapacity := (SELECT capacity FROM LimitedCourses WHERE code=OLD.course);
        inWaitingList := (1= (SELECT COUNT(student) from WaitingList where student = OLD.student AND course = OLD.course));

        IF OLD.student NOT IN (SELECT student FROM Registrations where course = OLD.course) 
            THEN    
                RAISE NOTICE '% is not in this course.----------', OLD.student;  
        END IF;

        IF  (studentsRegisteredOnCourse = courseCapacity) 
            AND (countPeopleInWaitingList > 0) 
            AND NOT inWaitingList
                THEN
                    idnrForPosition1 := (SELECT student FROM WaitingList WHERE course = OLD.course AND position = 1); 

                    RAISE NOTICE 'Removing student % from course %.', OLD.student, OLD.course;
                    DELETE FROM Registered WHERE student = OLD.student and course = OLD.course;

                    RAISE NOTICE 'Adding student % to course %', idnrForPosition1, OLD.course;
                    INSERT INTO registered VALUES (idnrForPosition1, OLD.course);
                    DELETE FROM WaitingList WHERE (course = OLD.course AND position = 1);

                    RAISE NOTICE 'Updating the position for all students';
                    UPDATE WaitingList SET position = position - 1 WHERE course = OLD.course;
                -- remove student from waitinglist position 1 and add that student to registered. decrement all 
                -- other waiting students queue position by 1
        END IF;
        IF (studentsRegisteredOnCourse) > (SELECT capacity FROM LimitedCourses WHERE code=OLD.course) 
            THEN    
                RAISE NOTICE 'The course is overbooked % students > % capacity.', studentsRegisteredOnCourse, courseCapacity;
                RAISE NOTICE 'only removing student % from course %.', OLD.student, OLD.course;
                DELETE FROM Registered WHERE student = OLD.student and course = OLD.course;
        END IF;
        IF (inWaitingList)
            THEN
                queuePosition := (SELECT position FROM WaitingList where student = OLD.student AND course = OLD.course);
                RAISE NOTICE 'Removing student % from waitingList, who had position %', OLD.student, queuePosition;
                DELETE FROM WaitingList WHERE (course = OLD.course and student = OLD.student);
                RAISE NOTICE 'fixing position of those behind.';
                UPDATE WaitingList SET position = position - 1 WHERE course = OLD.course and queuePosition < position;
        END IF;
        IF (countPeopleInWaitingList = 0)
            THEN
                DELETE FROM Registered WHERE student = OLD.student and course = OLD.course;    
        END IF;            
        RETURN OLD; 
    END $$
LANGUAGE PLPGSQL;



CREATE TRIGGER registerTrigger
    INSTEAD OF INSERT OR UPDATE ON Registrations  
    FOR EACH ROW EXECUTE PROCEDURE 
    registration();


CREATE TRIGGER unregisterTrigger
    INSTEAD OF DELETE ON Registrations
    FOR EACH ROW EXECUTE PROCEDURE
    unregistration();

