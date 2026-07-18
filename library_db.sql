USE library_db;

DROP TABLE IF EXISTS Logs, Penalties, Reservations, Loans, Books, Students, Admins;
-- Students table
CREATE TABLE Students (
    StudentID INT PRIMARY KEY,
    FullName VARCHAR(100),
    Field VARCHAR(50),
    Level ENUM('Undergraduate', 'Masters', 'PhD'),
    GPA DECIMAL(4,2),
    Email VARCHAR(100)
);

-- Books table
CREATE TABLE Books (
    BookID INT PRIMARY KEY AUTO_INCREMENT,
    Title VARCHAR(200),
    Author VARCHAR(100),
    Genre VARCHAR(50),
    ShelfCode VARCHAR(20),
    Status ENUM('Available', 'Loaned', 'Reserved', 'Lost') DEFAULT 'Available'
);

-- Admins table
CREATE TABLE Admins (
    AdminID INT PRIMARY KEY AUTO_INCREMENT,
    FullName VARCHAR(100),
    Username VARCHAR(50) UNIQUE,
    PasswordHash VARCHAR(255)
);

-- Loans table
CREATE TABLE Loans (
    LoanID INT PRIMARY KEY AUTO_INCREMENT,
    StudentID INT,
    BookID INT,
    LoanDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    DueDate DATE DEFAULT (DATE_ADD(CURRENT_DATE, INTERVAL 14 DAY)),
    ReturnDate DATE,
    FOREIGN KEY (StudentID) REFERENCES Students(StudentID),
    FOREIGN KEY (BookID) REFERENCES Books(BookID)
);

-- Penalties table
CREATE TABLE Penalties (
    PenaltyID INT PRIMARY KEY AUTO_INCREMENT,
    LoanID INT,
    DaysLate INT,
    Amount DECIMAL(10,2),
    Paid BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (LoanID) REFERENCES Loans(LoanID)
);

-- Reservations table
CREATE TABLE Reservations (
    ReservationID INT PRIMARY KEY AUTO_INCREMENT,
    BookID INT,
    StudentID INT,
    ReservationDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    Status ENUM('Active', 'Canceled', 'Fulfilled') DEFAULT 'Active',
    FOREIGN KEY (BookID) REFERENCES Books(BookID),
    FOREIGN KEY (StudentID) REFERENCES Students(StudentID)
);

-- Logs table showing what has changed
CREATE TABLE Logs (
    LogID INT PRIMARY KEY AUTO_INCREMENT,
    ActionType VARCHAR(50),
    Description TEXT,
    ActionTime TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- Triggers for updating tables based on some conditions

DELIMITER $$

-- Trigger for borrowing a book based on your level at uni
CREATE TRIGGER CheckLoanLimit
BEFORE INSERT ON Loans
FOR EACH ROW
BEGIN
    DECLARE maxBooks INT;
    DECLARE currentLoans INT;

    SELECT COUNT(*) INTO currentLoans
    FROM Loans
    WHERE StudentID = NEW.StudentID AND ReturnDate IS NULL;

    SELECT
        CASE
            WHEN Level = 'PhD' THEN 7
            WHEN Level = 'Masters' THEN 5
            WHEN Level = 'Undergraduate' AND GPA >= 17 THEN 5
            ELSE 4
        END
    INTO maxBooks
    FROM Students
    WHERE StudentID = NEW.StudentID;

-- Showing an error if student is borrowing more than their limit
    IF currentLoans >= maxBooks THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Exceeded loan limit for student level or GPA.';
    END IF;
END$$

-- Trigger for checking if the book has already been borrowed
CREATE TRIGGER SetBookLoaned
AFTER INSERT ON Loans
FOR EACH ROW
BEGIN
    UPDATE Books
    SET Status = 'Loaned'
    WHERE BookID = NEW.BookID;

    INSERT INTO Logs (ActionType, Description)
    VALUES ('Loan', CONCAT('Book ', NEW.BookID, ' loaned to student ', NEW.StudentID));
END$$

-- Trigger for making book available after returning it
CREATE TRIGGER SetBookAvailable
AFTER UPDATE ON Loans
FOR EACH ROW
BEGIN
    IF NEW.ReturnDate IS NOT NULL AND OLD.ReturnDate IS NULL THEN
        UPDATE Books
        SET Status = 'Available'
        WHERE BookID = NEW.BookID;

        INSERT INTO Logs (ActionType, Description)
        VALUES ('Return', CONCAT('Book ', NEW.BookID, ' returned by student ', NEW.StudentID));
        
        -- calculating the fine for returning late
        IF DATEDIFF(NEW.ReturnDate, NEW.DueDate) > 0 THEN
            INSERT INTO Penalties (LoanID, DaysLate, Amount)
            VALUES (NEW.LoanID, DATEDIFF(NEW.ReturnDate, NEW.DueDate), DATEDIFF(NEW.ReturnDate, NEW.DueDate) * 1000);
        END IF;
    END IF;
END$$

-- Trigger for updating logs
CREATE TRIGGER LogReservation
AFTER INSERT ON Reservations
FOR EACH ROW
BEGIN
    INSERT INTO Logs (ActionType, Description)
    VALUES ('Reservation', CONCAT('Student ', NEW.StudentID, ' reserved book ', NEW.BookID));
END$$

DELIMITER ;


-- Students
INSERT INTO Students (StudentID, FullName, Field, Level, GPA, Email) VALUES (1, 'Norma Fisher', 'Futures trader', 'Masters', 17.79, 'thull@yahoo.com');
INSERT INTO Students (StudentID, FullName, Field, Level, GPA, Email) VALUES (2, 'Steven Robinson', 'Corporate treasurer', 'Masters', 14.2, 'katelynmontgomery@yahoo.com');
INSERT INTO Students (StudentID, FullName, Field, Level, GPA, Email) VALUES (3, 'Ms. Michele Guzman', 'Data processing manager', 'PhD', 16.43, 'blairrachel@hotmail.com');
INSERT INTO Students (StudentID, FullName, Field, Level, GPA, Email) VALUES (4, 'Justin Gomez', 'Interpreter', 'Masters', 18.84, 'hramos@brown-sellers.com');
INSERT INTO Students (StudentID, FullName, Field, Level, GPA, Email) VALUES (5, 'Ryan Page', 'Accommodation manager', 'Masters', 16.92, 'john51@gmail.com');
INSERT INTO Students (StudentID, FullName, Field, Level, GPA, Email) VALUES (6, 'Connie Pratt', 'Curator', 'Undergraduate', 16.52, 'millerluke@hotmail.com');
INSERT INTO Students (StudentID, FullName, Field, Level, GPA, Email) VALUES (7, 'Kayla Decker', 'Production assistant', 'Masters', 17.93, 'crystal83@gmail.com');
INSERT INTO Students (StudentID, FullName, Field, Level, GPA, Email) VALUES (8, 'Kara Barnes', 'Clinical psychologist', 'PhD', 18.89, 'edavis@gmail.com');
INSERT INTO Students (StudentID, FullName, Field, Level, GPA, Email) VALUES (9, 'Debbie Hamilton', 'Naval architect', 'PhD', 18.92, 'mdonaldson@gmail.com');
INSERT INTO Students (StudentID, FullName, Field, Level, GPA, Email) VALUES (10, 'Timothy Daniels', 'Emergency planning manager', 'Undergraduate', 16.72, 'bmoore@hotmail.com');

-- Books
INSERT INTO Books (Title, Author, Genre, ShelfCode) VALUES ('Product sit model.', 'Philip Johnston', 'cloud', 'S001');
INSERT INTO Books (Title, Author, Genre, ShelfCode) VALUES ('Low owner car.', 'Jennifer Olson', 'mobile', 'S002');
INSERT INTO Books (Title, Author, Genre, ShelfCode) VALUES ('High final number.', 'Thomas Robinson', 'data', 'S003');
INSERT INTO Books (Title, Author, Genre, ShelfCode) VALUES ('Make professor growth.', 'Melissa Wilson', 'ml', 'S004');
INSERT INTO Books (Title, Author, Genre, ShelfCode) VALUES ('Message dog effort.', 'Christine Turner', 'robotics', 'S005');
INSERT INTO Books (Title, Author, Genre, ShelfCode) VALUES ('Guy good people.', 'Aaron Morris', 'security', 'S006');
INSERT INTO Books (Title, Author, Genre, ShelfCode) VALUES ('Why month serve.', 'Elizabeth Moore', 'web', 'S007');
INSERT INTO Books (Title, Author, Genre, ShelfCode) VALUES ('Fine hear program.', 'Amy Parker', 'devops', 'S008');
INSERT INTO Books (Title, Author, Genre, ShelfCode) VALUES ('Write hundred stage.', 'Kathleen Miller', 'dbms', 'S009');
INSERT INTO Books (Title, Author, Genre, ShelfCode) VALUES ('Speech performance draw.', 'Joshua Sullivan', 'iot', 'S010');

-- Admins
INSERT INTO Admins (FullName, Username, PasswordHash) VALUES ('Richard Bell', 'user1', SHA2('pass1', 256));
INSERT INTO Admins (FullName, Username, PasswordHash) VALUES ('Christopher Rose', 'user2', SHA2('pass2', 256));
INSERT INTO Admins (FullName, Username, PasswordHash) VALUES ('Gregory Wilson', 'user3', SHA2('pass3', 256));
INSERT INTO Admins (FullName, Username, PasswordHash) VALUES ('Kathryn Anderson', 'user4', SHA2('pass4', 256));
INSERT INTO Admins (FullName, Username, PasswordHash) VALUES ('Barbara Evans', 'user5', SHA2('pass5', 256));
INSERT INTO Admins (FullName, Username, PasswordHash) VALUES ('Anna Green', 'user6', SHA2('pass6', 256));
INSERT INTO Admins (FullName, Username, PasswordHash) VALUES ('Joseph Moore', 'user7', SHA2('pass7', 256));
INSERT INTO Admins (FullName, Username, PasswordHash) VALUES ('Brittany Perry', 'user8', SHA2('pass8', 256));
INSERT INTO Admins (FullName, Username, PasswordHash) VALUES ('Gary Kelly', 'user9', SHA2('pass9', 256));
INSERT INTO Admins (FullName, Username, PasswordHash) VALUES ('Carolyn Johnson', 'user10', SHA2('pass10', 256));

-- Loans
INSERT INTO Loans (StudentID, BookID, LoanDate, DueDate) VALUES (6, 3, '2025-05-03', '2025-05-21');
INSERT INTO Loans (StudentID, BookID, LoanDate, DueDate) VALUES (9, 2, '2025-05-05', '2025-05-20');
INSERT INTO Loans (StudentID, BookID, LoanDate, DueDate) VALUES (1, 6, '2025-05-07', '2025-05-15');
INSERT INTO Loans (StudentID, BookID, LoanDate, DueDate) VALUES (7, 9, '2025-05-02', '2025-05-18');
INSERT INTO Loans (StudentID, BookID, LoanDate, DueDate) VALUES (6, 7, '2025-05-06', '2025-05-22');
INSERT INTO Loans (StudentID, BookID, LoanDate, DueDate) VALUES (4, 2, '2025-05-09', '2025-05-21');
INSERT INTO Loans (StudentID, BookID, LoanDate, DueDate) VALUES (4, 10, '2025-05-03', '2025-05-15');
INSERT INTO Loans (StudentID, BookID, LoanDate, DueDate) VALUES (2, 5, '2025-05-07', '2025-05-20');
INSERT INTO Loans (StudentID, BookID, LoanDate, DueDate) VALUES (1, 3, '2025-05-01', '2025-05-23');
INSERT INTO Loans (StudentID, BookID, LoanDate, DueDate) VALUES (3, 5, '2025-05-05', '2025-05-24');

-- Penalties
INSERT INTO Penalties (LoanID, DaysLate, Amount) VALUES (3, 6, 6000);
INSERT INTO Penalties (LoanID, DaysLate, Amount) VALUES (2, 7, 7000);
INSERT INTO Penalties (LoanID, DaysLate, Amount) VALUES (5, 8, 8000);
INSERT INTO Penalties (LoanID, DaysLate, Amount) VALUES (10, 4, 4000);
INSERT INTO Penalties (LoanID, DaysLate, Amount) VALUES (7, 2, 2000);

-- Reservations
INSERT INTO Reservations (BookID, StudentID, ReservationDate) VALUES (5, 7, '2025-05-13');
INSERT INTO Reservations (BookID, StudentID, ReservationDate) VALUES (3, 1, '2025-05-09');
INSERT INTO Reservations (BookID, StudentID, ReservationDate) VALUES (1, 4, '2025-05-05');
INSERT INTO Reservations (BookID, StudentID, ReservationDate) VALUES (8, 10, '2025-05-07');
INSERT INTO Reservations (BookID, StudentID, ReservationDate) VALUES (7, 6, '2025-05-03');
INSERT INTO Reservations (BookID, StudentID, ReservationDate) VALUES (9, 2, '2025-05-14');
INSERT INTO Reservations (BookID, StudentID, ReservationDate) VALUES (2, 3, '2025-05-11');
INSERT INTO Reservations (BookID, StudentID, ReservationDate) VALUES (6, 5, '2025-05-08');
INSERT INTO Reservations (BookID, StudentID, ReservationDate) VALUES (10, 9, '2025-05-01');
INSERT INTO Reservations (BookID, StudentID, ReservationDate) VALUES (4, 8, '2025-05-10');

-- Logs
INSERT INTO Logs (ActionType, Description) VALUES ('Manual', 'Test log 1 for review');
INSERT INTO Logs (ActionType, Description) VALUES ('Manual', 'Test log 2 for review');
INSERT INTO Logs (ActionType, Description) VALUES ('Manual', 'Test log 3 for review');
INSERT INTO Logs (ActionType, Description) VALUES ('Manual', 'Test log 4 for review');
INSERT INTO Logs (ActionType, Description) VALUES ('Manual', 'Test log 5 for review');
