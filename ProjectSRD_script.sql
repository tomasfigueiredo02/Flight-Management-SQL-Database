-- -----------------------------------------------------
-- Group 36
-- -----------------------------------------------------
-- Afonso Ascenção - Student number: 20240684
-- Duarte Marques - Student number: 20240522
-- Joana Esteves - Student number: 20240746
-- Rita Serra - Student number: 20240515
-- Tomás Figueiredo - Student number: 20240941
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema airline
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS airline DEFAULT CHARACTER SET utf8;
-- -----------------------------------------------------
-- Schema airline
-- -----------------------------------------------------
USE airline;
-- -----------------------------------------------------


-- -----------------------------------------------------
-- Tables
-- -----------------------------------------------------

CREATE TABLE IF NOT EXISTS Company (
    company_id INT UNSIGNED NOT NULL UNIQUE AUTO_INCREMENT,
    restriction enum('1') UNIQUE NOT NULL,
    company_name VARCHAR(100) NOT NULL,
    company_address VARCHAR(255) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(9) NOT NULL,
    
	--
	CONSTRAINT pk_company
		PRIMARY KEY (company_id)
);


CREATE TABLE IF NOT EXISTS Aircrafts (
    aircraft_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    brand VARCHAR(40) NOT NULL,
    capacity INT UNSIGNED NOT NULL,
    manufactured_year INT NOT NULL,
    company_id INT UNSIGNED NOT NULL,
    
    --
	CONSTRAINT pk_aircrafts
		PRIMARY KEY (aircraft_id),
        
	CONSTRAINT fk_aircrafts
    FOREIGN KEY (company_id) REFERENCES Company(company_id)
        ON DELETE RESTRICT
		ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS Airports (
    airport_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    airport_city VARCHAR(50) NOT NULL,
    airport_country VARCHAR(50) NOT NULL,
    
    --
	CONSTRAINT pk_airports
		PRIMARY KEY (airport_id)
	
);

CREATE TABLE IF NOT EXISTS Flights (
    flight_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    departure_time DATETIME NOT NULL,
    arrival_time DATETIME NOT NULL,
    origin_airport INT UNSIGNED NOT NULL,
    destination_airport INT UNSIGNED NOT NULL,
    aircraft_id INT UNSIGNED NOT NULL,
    
    --
	CONSTRAINT pk_flights
		PRIMARY KEY (flight_id),
        
	--
	CONSTRAINT fk_flights 
		FOREIGN KEY (origin_airport) REFERENCES Airports(airport_id)
        ON DELETE RESTRICT
		ON UPDATE CASCADE,
        
		FOREIGN KEY (destination_airport) REFERENCES Airports(airport_id)
        ON DELETE RESTRICT
		ON UPDATE CASCADE,
        
		FOREIGN KEY (aircraft_id) REFERENCES Aircrafts(aircraft_id)
        ON DELETE RESTRICT
		ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS Payments (
    payment_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    payment_method ENUM('Credit Card', 'Bank transfer', 'PayPal', 'Online Banking', 'WeChat Pay', 'Alipay'),
    state ENUM('Confirmed', 'Pending', 'Failed') NOT NULL,
    
	--
	CONSTRAINT pk_payments
		PRIMARY KEY (payment_id)
);


CREATE TABLE IF NOT EXISTS Passengers (
    passenger_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(40) NOT NULL UNIQUE,
    phone VARCHAR(15) NOT NULL UNIQUE,
    
	--
	CONSTRAINT pk_passengers
		PRIMARY KEY (passenger_id)
);

CREATE TABLE IF NOT EXISTS Clients (
    client_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    passenger_id INT UNSIGNED NOT NULL,
    first_name VARCHAR(40) NOT NULL,
    last_name VARCHAR(40) NOT NULL,
    address VARCHAR(255) NOT NULL,
    
    --
    CONSTRAINT pk_clients
		PRIMARY KEY (client_id),
	
	--
	CONSTRAINT fk_Clients
		FOREIGN KEY (passenger_id) REFERENCES Passengers(passenger_id)
        ON DELETE RESTRICT
		ON UPDATE CASCADE
);


CREATE TABLE IF NOT EXISTS Purchases (
    purchase_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    client_id INT UNSIGNED NULL,
    payment_id INT UNSIGNED NOT NULL,
    tax_rate DECIMAL(3, 2) NOT NULL,
    discount_rate DECIMAL(3, 2) NOT NULL,
    purchase_time DATETIME NOT NULL,
    state ENUM('Confirmed', 'Waiting payment', 'Cancelled') NOT NULL,
    
	--
	CONSTRAINT pk_purchases
		PRIMARY KEY (purchase_id),
        
	CONSTRAINT fk_purchases
		FOREIGN KEY (client_id) REFERENCES Clients(client_id)
        ON DELETE RESTRICT
		ON UPDATE CASCADE,
        
        FOREIGN KEY (payment_id) REFERENCES Payments(payment_id)
        ON DELETE RESTRICT
		ON UPDATE CASCADE
        
);

CREATE TABLE IF NOT EXISTS Check_In (
    check_in_code INT UNSIGNED NOT NULL AUTO_INCREMENT,
    check_in_date DATETIME,
    check_in_status ENUM("Completed", "Pending", "Missed"),
    
	--
	CONSTRAINT pk_checkins
		PRIMARY KEY (check_in_code)
        
);

CREATE TABLE IF NOT EXISTS Reviews (
    review_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    rating INT NOT NULL,
    content TEXT NOT NULL,
    
	--
	CONSTRAINT pk_reviews
		PRIMARY KEY (review_id)
	
);

CREATE TABLE IF NOT EXISTS Bookings (
    booking_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    flight_id INT UNSIGNED NOT NULL,
    check_in_code INT UNSIGNED NOT NULL,
    review_id INT UNSIGNED NOT NULL,
    passenger_id INT UNSIGNED NOT NULL,
    purchase_id INT UNSIGNED NOT NULL,
    unitary_cost DECIMAL(5, 2) NOT NULL,
    
	--
	CONSTRAINT pk_bookings
		PRIMARY KEY (booking_id),
        
	--
	CONSTRAINT fk_bookings
		FOREIGN KEY (flight_id) REFERENCES Flights(flight_id)
        ON DELETE RESTRICT
		ON UPDATE CASCADE,
        
		FOREIGN KEY (passenger_id) REFERENCES Passengers(passenger_id)
        ON DELETE RESTRICT
		ON UPDATE CASCADE,
        
		FOREIGN KEY (purchase_id) REFERENCES Purchases(purchase_id)
        ON DELETE RESTRICT
		ON UPDATE CASCADE,
        
        FOREIGN KEY (check_in_code) REFERENCES Check_In(check_in_code)
        ON DELETE RESTRICT
		ON UPDATE CASCADE,
        
        FOREIGN KEY (review_id) REFERENCES Reviews(review_id)
        ON DELETE RESTRICT
		ON UPDATE CASCADE
);


CREATE TABLE IF NOT EXISTS Employees (
    employee_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    employee_role VARCHAR(50) NOT NULL,
    hire_date DATE NOT NULL,
    company_id INT UNSIGNED NOT NULL,
    
	--
	CONSTRAINT pk_employees
		PRIMARY KEY (employee_id),
    CONSTRAINT fk_employees    
        FOREIGN KEY (company_id) REFERENCES Company(company_id)
        ON DELETE RESTRICT
		ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS Flight_crew (
    flight_id INT UNSIGNED NOT NULL,
    employee_id INT UNSIGNED NOT NULL,
    
	--
	CONSTRAINT pk_flightcrew
		PRIMARY KEY (flight_id,employee_id),
    
	--
	CONSTRAINT fk_flightcrew
		FOREIGN KEY (flight_id) REFERENCES Flights(flight_id)
        ON DELETE RESTRICT
		ON UPDATE CASCADE,
		FOREIGN KEY (employee_id) REFERENCES Employees(employee_id)
        ON DELETE RESTRICT
		ON UPDATE CASCADE
);


CREATE TABLE IF NOT EXISTS Logs (
    log_entry_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    log_time DATETIME,
    log_user VARCHAR(20),
    log_message VARCHAR(200),
    
	--
	CONSTRAINT pk_logs
		PRIMARY KEY (log_entry_id)
);


-- -----------------------------------------------------
-- Triggers
-- -----------------------------------------------------
DELIMITER //

CREATE TRIGGER Check_Purchase_State
BEFORE UPDATE ON Purchases
FOR EACH ROW
BEGIN
    DECLARE payment_state ENUM('Confirmed', 'Pending', 'Failed');

    SELECT Payments.state INTO payment_state
    FROM Payments
    WHERE Payments.payment_id = NEW.payment_id;

    IF NEW.state = 'Confirmed' AND payment_state != 'Confirmed' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Purchase cannot be confirmed unless the payment is completed.';
    END IF;
END;
//

CREATE TRIGGER Check_Booking_Capacity
BEFORE INSERT ON Bookings
FOR EACH ROW
BEGIN
    DECLARE total_bookings INT;
    DECLARE aircraft_capacity INT;

    SELECT COUNT(*) INTO total_bookings
    FROM Bookings
    WHERE flight_id = NEW.flight_id;

    SELECT Aircrafts.capacity INTO aircraft_capacity
    FROM Flights
    INNER JOIN Aircrafts ON Flights.aircraft_id = Aircrafts.aircraft_id
    WHERE Flights.flight_id = NEW.flight_id;

    IF total_bookings >= aircraft_capacity THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Maximum number of bookings for this flight was reached.';
    END IF;
END;
//


CREATE TRIGGER Delete_bookings_on_purchase_cancel
AFTER UPDATE ON Purchases
FOR EACH ROW
BEGIN
    -- Checks if the purchase has been canceled
    IF OLD.state != 'Cancelled' AND NEW.state = 'Cancelled' THEN
        
        -- Deletes the bookings related to the canceled purchase
        DELETE FROM Bookings WHERE purchase_id = NEW.purchase_id;

        -- Logs the action
        INSERT INTO Logs (log_time,log_user, log_message)
        VALUES (NOW(), USER(),CONCAT('Bookings for purchase ID ', NEW.purchase_id, ' were deleted due to cancellation.'));
    END IF;
END
//

DELIMITER ;


-- -----------------------------------------------------
-- Inserts
-- -----------------------------------------------------

INSERT INTO Company (restriction,company_name, company_address, email, phone)
VALUES
('1','Company123', 'Christmas Street', 'company@company123.com', '962425678');


-- Insert data for Aircrafts
INSERT INTO Aircrafts (brand, capacity, manufactured_year, company_id)
VALUES
('Boeing', 180, 2010,1),
('Airbus', 200, 2012,1),
('Embraer', 100, 2015,1),
('Boeing', 220, 2018,1),
('Airbus', 150, 2013,1),
('Bombardier', 75, 2020,1),
('Cessna', 50, 2017,1),
('Boeing', 300, 2016,1),
('Airbus', 320, 2019,1),
('Embraer', 120, 2014,1),
('Bombardier', 90, 2021,1),
('Cessna', 60, 2011,1),
('Boeing', 400, 2008,1),
('Airbus', 280, 2022,1),
('Embraer', 130, 2015,1),
('Bombardier', 100, 2020,1),
('Cessna', 70, 2018,1),
('Boeing', 180, 2023,1),
('Airbus', 200, 2021,1),
('Embraer', 110, 2020,1);

-- Insert data for Airports
INSERT INTO Airports (airport_city, airport_country)
VALUES
('New York', 'USA'),
('Los Angeles', 'USA'),
('London', 'UK'),
('Tokyo', 'Japan'),
('Paris', 'France'),
('Berlin', 'Germany'),
('Dubai', 'UAE'),
('Beijing', 'China'),
('Sydney', 'Australia'),
('Toronto', 'Canada'),
('Mumbai', 'India'),
('Rome', 'Italy'),
('Singapore', 'Singapore'),
('Hong Kong', 'China'),
('Madrid', 'Spain'),
('Istanbul', 'Turkey'),
('Seoul', 'South Korea'),
('Bangkok', 'Thailand'),
('Mexico City', 'Mexico'),
('Johannesburg', 'South Africa');

-- Insert data for Flights
INSERT INTO Flights (departure_time, arrival_time, origin_airport, destination_airport, aircraft_id)
VALUES
('2023-12-12 08:00:00', '2023-12-12 12:00:00', 1, 2, 4),
('2023-11-10 13:00:00', '2023-11-10 17:30:00', 2, 3, 20),
('2022-10-05 07:15:00', '2022-10-05 12:45:00', 3, 4, 12),
('2022-12-25 20:00:00', '2022-12-26 00:00:00', 4, 5, 4),
('2023-06-15 09:30:00', '2023-06-15 14:00:00', 5, 6, 3),
('2023-03-20 06:45:00', '2023-03-20 11:15:00', 6, 7, 6),
('2022-07-01 19:00:00', '2022-07-01 23:30:00', 7, 8, 7),
('2023-01-14 11:00:00', '2023-01-14 15:00:00', 8, 9, 8),
('2022-10-11 15:30:00', '2022-10-11 19:30:00', 5, 3, 6),
('2023-05-04 15:30:00', '2023-05-04 19:30:00', 9, 10, 9),
('2023-02-18 15:30:00', '2023-02-18 19:30:00', 19, 10, 13),
('2022-12-17 15:30:00', '2022-12-17 19:30:00', 7, 8, 9),
('2023-02-18 15:30:00', '2023-02-18 19:30:00', 9, 8, 1),
('2023-01-10 14:30:00', '2023-01-10 18:30:00', 14, 10, 11),
('2022-11-05 12:00:00', '2022-11-05 16:30:00', 10, 11, 10),
('2022-09-10 07:00:00', '2022-09-10 11:45:00', 11, 12, 11),
('2023-08-25 14:30:00', '2023-08-25 18:30:00', 12, 13, 5),
('2023-07-18 16:00:00', '2023-07-18 20:00:00', 16, 14, 13),
('2022-05-25 05:30:00', '2022-05-25 10:15:00', 14, 15, 14),
('2023-09-30 20:45:00', '2023-09-30 01:15:00', 15, 13, 15),
('2022-02-15 09:00:00', '2022-02-15 13:30:00', 16, 17, 16),
('2023-11-22 22:00:00', '2023-11-23 03:00:00', 17, 1, 17),
('2022-06-10 13:15:00', '2022-06-10 17:45:00', 18, 19, 18),
('2023-05-12 15:00:00', '2023-05-12 19:30:00', 2, 20, 19),
('2022-04-01 16:00:00', '2022-04-01 20:30:00', 20, 1, 2),
('2022-08-12 15:00:00', '2022-08-12 19:30:00', 15, 13, 1),
('2023-01-10 13:15:00', '2023-01-10 17:45:00', 12, 13, 3),
('2023-10-12 09:00:00', '2023-10-12 13:00:00', 7, 8, 5);

-- Insert data for Payments
INSERT INTO Payments (payment_method, state)
VALUES
('Credit Card', 'Confirmed'),
('Bank transfer', 'Pending'),
('PayPal', 'Failed'),
('Online Banking', 'Confirmed'),
('WeChat Pay', 'Confirmed'),
('Alipay', 'Pending'),
('Credit Card', 'Failed'),
('Bank transfer', 'Confirmed'),
('PayPal', 'Confirmed'),
('Online Banking', 'Pending'),
('WeChat Pay', 'Failed'),
('Alipay', 'Confirmed'),
('Credit Card', 'Confirmed'),
('Bank transfer', 'Failed'),
('PayPal', 'Pending'),
('Online Banking', 'Failed'),
('WeChat Pay', 'Pending'),
('Alipay', 'Confirmed'),
('Credit Card', 'Pending'),
('Bank transfer', 'Confirmed');

-- Insert data for Passengers
INSERT INTO Passengers (first_name, last_name, email, phone)
VALUES
('John', 'Doe', 'john.doe@gmail.com', '914567890'),
('Jane', 'Smith', 'jane.smith@yahoo.com', '934567901'),
('Alice', 'Johnson', 'alice.johnson@hotmail.com', '934789012'),
('Bob', 'Brown', 'bob.brown@gmail.com', '917890123'),
('Charlie', 'Davis', 'charlie.davis@gmail.com', '967801234'),
('Diana', 'Evans', 'diana.evans@gmail.com', '967890125'),
('Ethan', 'Foster', 'ethan.foster@gmail.com', '910123456'),
('Fiona', 'Green', 'fiona.green@gmail.com', '912345667'),
('George', 'Hill', 'george.hill@gmail.com', '961345678'),
('Hannah', 'Ivy', 'hannah.ivy@gmail.com', '931267891'),
('Ian', 'Jones', 'ian.jones@gmail.com', '934678902'),
('Julia', 'King', 'julia.king@gmail.com', '916789013'),
('Kevin', 'Lewis', 'kevin.lewis@gmail.com', '967890124'),
('Laura', 'Moore', 'laura.moore@gmail.com', '967899235'),
('Michael', 'Nelson', 'michael.nelson@gmail.com', '911012346'),
('Nina', 'Owens', 'nina.owens@gmail.com', '920123457'),
('Oscar', 'Perez', 'oscar.perez@gmail.com', '922123568'),
('Paula', 'Quinn', 'paula.quinn@gmail.com', '934345679'),
('Quinn', 'Roberts', 'quinn.roberts@gmail.com', '913567892'),
('Ryan', 'Stevens', 'ryan.stevens@gmail.com', '934567893'),
('May','Parker', 'parker@hotmail.com', '924536711'),
('Liam', 'Martinez', 'liam_martinezz@gmail.com', '911110002'),
('Jack', 'Daniels', 'jack.daniels@gmail.com', '923536924'),
('Johnie', 'Walker', 'johnie.walker@gmail.com', '927382043');

-- Insert data for Clients
INSERT INTO Clients (passenger_id, first_name, last_name, address)
VALUES
(1, 'John', 'Doe', '123 Elm Street, New York, USA'),
(2, 'Jane', 'Smith', '456 Oak Avenue, Los Angeles, USA'),
(3, 'Alice', 'Johnson', '789 Pine Road, London, UK'),
(4, 'Bob', 'Brown', '101 Maple Lane, Tokyo, Japan'),
(5, 'Charlie', 'Davis', '202 Cedar Blvd, Paris, France'),
(6, 'Diana', 'Evans', '303 Birch Drive, Berlin, Germany'),
(7, 'Ethan', 'Foster', '404 Spruce Ct, Dubai, UAE'),
(8, 'Fiona', 'Green', '505 Ash Ave, Beijing, China'),
(9, 'George', 'Hill', '606 Redwood St, Sydney, Australia'),
(10, 'Hannah', 'Ivy', '707 Cypress Way, Toronto, Canada'),
(11, 'Ian', 'Jones', '808 Willow Ln, Mumbai, India'),
(12, 'Julia', 'King', '909 Palm Circle, Rome, Italy'),
(13, 'Kevin', 'Lewis', '1010 Fir St, Singapore, Singapore'),
(14, 'Laura', 'Moore', '1111 Aspen Rd, Hong Kong, China'),
(15, 'Michael', 'Nelson', '1212 Magnolia Blvd, Madrid, Spain'),
(16, 'Nina', 'Owens', '1313 Chestnut Ln, Istanbul, Turkey'),
(17, 'Oscar', 'Perez', '1414 Dogwood Dr, Seoul, South Korea'),
(18, 'Paula', 'Quinn', '1515 Juniper Ave, Bangkok, Thailand'),
(19, 'Quinn', 'Roberts', '1616 Poplar Ct, Mexico City, Mexico'),
(20, 'Ryan', 'Stevens', '1717 Sequoia Blvd, Johannesburg, South Africa'),
(21, 'May','Parker', '45 Sunset Drive, Toronto, Canada'),
(22, 'Liam', 'Martinez', '89 Maple Street, Melbourne, Australia'),
(23, 'Don', 'Quixote', 'Evergreen Place, Springfield');

-- Insert data for Purchases
INSERT INTO Purchases (client_id, payment_id, tax_rate, discount_rate, purchase_time, state)
VALUES
(1, 1, 0.07, 0.10, '2023-12-12 10:00:00', 'Confirmed'),
(2, 2, 0.05, 0.05, '2023-11-15 11:00:00', 'Waiting payment'),
(3, 3, 0.10, 0.15, '2022-10-01 12:00:00', 'Cancelled'),
(4, 4, 0.07, 0.10, '2022-12-20 13:00:00', 'Confirmed'),
(5, 5, 0.06, 0.12, '2023-06-10 14:00:00', 'Confirmed'),
(6, 6, 0.08, 0.08, '2023-03-15 15:00:00', 'Waiting payment'),
(7, 7, 0.05, 0.05, '2022-07-10 16:00:00', 'Cancelled'),
(8, 8, 0.09, 0.10, '2023-01-10 17:00:00', 'Confirmed'),
(9, 9, 0.04, 0.07, '2023-02-20 18:00:00', 'Confirmed'),
(10, 10, 0.06, 0.09, '2022-11-01 19:00:00', 'Waiting payment'),
(11, 11, 0.05, 0.11, '2022-09-05 20:00:00', 'Cancelled'),
(12, 12, 0.07, 0.10, '2023-08-10 21:00:00', 'Confirmed'),
(13, 13, 0.06, 0.12, '2023-07-01 22:00:00', 'Confirmed'),
(14, 14, 0.08, 0.13, '2022-05-20 23:00:00', 'Cancelled'),
(15, 15, 0.07, 0.10, '2023-09-25 08:00:00', 'Confirmed'),
(16, 16, 0.05, 0.08, '2022-02-10 09:00:00', 'Cancelled'),
(17, 17, 0.06, 0.09, '2023-11-15 10:00:00', 'Confirmed'),
(18, 18, 0.05, 0.05, '2022-06-05 11:00:00', 'Cancelled'),
(19, 19, 0.07, 0.10, '2023-05-10 12:00:00', 'Confirmed'),
(20, 20, 0.08, 0.08, '2022-04-10 13:00:00', 'Cancelled'),
(21, 1, 0.05, 0.05, '2022-01-08 10:00:00', 'Confirmed'),
(22, 5, 0.06, 0.02, '2022-11-29 23:00:00', 'Confirmed'),
(23, 5, 0.06, 0.02, '2022-11-29 23:00:00', 'Confirmed');


-- Insert data for Check_In
INSERT INTO Check_In (check_in_date, check_in_status)
VALUES
('2023-12-12 07:00:00', 'Completed'),
('2023-11-10 10:00:00', 'Pending'),
('2022-10-01 06:30:00', 'Missed'),
('2022-12-20 18:30:00', 'Completed'),
('2023-06-10 08:45:00', 'Completed'),
('2023-03-15 05:30:00', 'Pending'),
('2022-07-10 15:15:00', 'Missed'),
('2023-01-10 14:30:00', 'Completed'),
('2023-02-20 17:00:00', 'Completed'),
('2022-11-01 08:00:00', 'Pending'),
('2022-09-05 07:45:00', 'Missed'),
('2023-08-10 19:15:00', 'Completed'),
('2023-07-01 12:30:00', 'Completed'),
('2022-05-20 11:45:00', 'Missed'),
('2023-09-25 06:30:00', 'Completed'),
('2022-02-10 05:15:00', 'Missed'),
('2023-11-15 16:45:00', 'Completed'),
('2022-06-05 15:00:00', 'Missed'),
('2023-05-10 13:15:00', 'Completed'),
('2022-04-10 10:30:00', 'Missed'),
('2022-08-12 13:30:00', 'Completed'),
('2023-01-10 12:30:00', 'Missed'),
('2023-01-10 12:30:00', 'Completed');

-- Insert data for Reviews
INSERT INTO Reviews (rating, content)
VALUES
(5, 'Excellent flight, very comfortable.'),
(4, 'Good service but minor delays.'),
(3, 'Average experience, nothing special.'),
(2, 'Flight was delayed and service was poor.'),
(5, 'Amazing crew and smooth flight.'),
(4, 'Good value for money.'),
(1, 'Horrible experience, will not book again.'),
(5, 'Loved every aspect of the journey.'),
(3, 'Mediocre flight, room for improvement.'),
(4, 'Pleasant trip overall.'),
(2, 'Disappointed with the cleanliness.'),
(5, 'Perfect experience from start to finish.'),
(4, 'Satisfied with the service.'),
(3, 'Could have been better, but okay overall.'),
(5, 'Fantastic flight, very professional staff.'),
(2, 'Seats were cramped and uncomfortable.'),
(4, 'Enjoyable flight experience.'),
(1, 'Very poor experience, do not recommend.'),
(5, 'Outstanding service and punctuality.'),
(4, 'Nice flight overall.'),
(5, 'Five Stars.'),
(4, 'Great service.'),
(3, 'Average flight.');

-- Insert data for Bookings
INSERT INTO Bookings (flight_id, check_in_code, review_id, passenger_id, purchase_id, unitary_cost)
VALUES
(1, 1, 1, 1, 1, 150.00),
(1, 2, 2, 2, 2, 200.00),
(3, 3, 3, 3, 3, 180.00),
(4, 4, 4, 4, 4, 220.00),
(5, 5, 5, 5, 5, 250.00),
(6, 6, 6, 6, 6, 170.00),
(7, 7, 7, 7, 7, 190.00),
(8, 8, 8, 8, 8, 300.00),
(9, 9, 9, 9, 9, 210.00),
(10, 10, 10, 10, 10, 240.00),
(11, 11, 11, 11, 11, 160.00),
(12, 12, 12, 12, 12, 230.00),
(13, 13, 13, 13, 13, 280.00),
(14, 14, 14, 14, 14, 270.00),
(15, 15, 15, 15, 15, 260.00),
(16, 16, 16, 16, 16, 310.00),
(17, 17, 17, 17, 17, 330.00),
(18, 18, 18, 18, 18, 290.00),
(19, 19, 19, 19, 19, 220.00),
(20, 20, 20, 20, 20, 340.00),
(26, 21, 21, 21, 21, 340.00),
(27, 22, 22, 22, 22, 300.00),
(28, 23, 23, 23, 23, 200.00);


INSERT INTO Employees (first_name, last_name, employee_role, hire_date, company_id)
VALUES
('John', 'Smith', 'Pilot', '2015-06-15',1),
('Mary', 'Johnson', 'Co-Pilot', '2017-03-20',1),
('Michael', 'Williams', 'Flight Attendant', '2018-08-10',1),
('Elizabeth', 'Brown', 'Flight Attendant', '2019-11-25',1),
('David', 'Jones', 'Pilot', '2016-04-01',1),
('Jennifer', 'Garcia', 'Co-Pilot', '2020-07-15',1),
('Robert', 'Martinez', 'Ground Crew', '2014-12-10',1),
('Patricia', 'Hernandez', 'Flight Attendant', '2021-05-30',1),
('William', 'Lopez', 'Engineer', '2013-09-20',1),
('Linda', 'Clark', 'Flight Attendant', '2022-01-18',1),
('James', 'Moore', 'Pilot', '2018-04-22',1),
('Barbara', 'Anderson', 'Flight Attendant', '2017-11-14',1),
('Christopher', 'Thomas', 'Ground Crew', '2021-02-25',1),
('Susan', 'Taylor', 'Co-Pilot', '2019-09-08',1),
('Joseph', 'Lee', 'Flight Attendant', '2020-03-12',1),
('Karen', 'Perez', 'Flight Attendant', '2022-08-05',1),
('Thomas', 'White', 'Engineer', '2015-12-19',1),
('Margaret', 'Harris', 'Flight Attendant', '2016-06-10',1),
('Charles', 'Martin', 'Ground Crew', '2014-04-15',1),
('Emily', 'Thompson', 'Pilot', '2023-01-01',1);

INSERT INTO Flight_crew (flight_id, employee_id)
VALUES
(1, 1),
(1, 2),
(1, 3),
(2, 4),
(2, 5),
(2, 6),
(3, 7),
(3, 8),
(3, 9),
(4, 10),
(4, 11),
(4, 12),
(5, 13),
(5, 14),
(5, 15),
(6, 16),
(6, 17),
(6, 18),
(7, 19),
(7, 20),
(8,1),
(8,3),
(8,18),
(26,2),
(26,18),
(26,20);



-- -----------------------------------------------------
-- Invoice
-- -----------------------------------------------------

CREATE VIEW InvoiceHeader AS
SELECT
    Purchases.purchase_id AS InvoiceID,
    NOW() AS InvoiceDate,
    Clients.first_name AS ClientFirstName,
    Clients.last_name AS ClientLastName,
    Clients.address AS ClientAddress,
    Company.company_name AS CompanyName,
    Company.company_address AS CompanyAddress,
    Company.email AS CompanyEmail,
    Company.phone AS CompanyPhone,
    SUM(Bookings.unitary_cost) AS TotalCost,
    SUM(Bookings.unitary_cost) * Purchases.discount_rate AS Discount,
    SUM(Bookings.unitary_cost) * Purchases.tax_rate AS Tax,
    (SUM(Bookings.unitary_cost) 
        - SUM(Bookings.unitary_cost) * Purchases.discount_rate 
        + SUM(Bookings.unitary_cost) * Purchases.tax_rate) AS FinalTotal
FROM
    Purchases
JOIN
    Clients ON Purchases.client_id = Clients.client_id
JOIN
    Bookings ON Purchases.purchase_id = Bookings.purchase_id
JOIN
    Flights ON Bookings.flight_id = Flights.flight_id
JOIN
    Company ON 1 = 1
GROUP BY
    Purchases.purchase_id, Clients.first_name, Clients.last_name, Clients.address,
    Company.company_name, Company.company_address, Company.email, Company.phone;


CREATE VIEW InvoiceDetails AS
SELECT
    Purchases.purchase_id AS InvoiceID,
    CONCAT('Ticket for the flight number: ', Flights.flight_id) AS Description,
    Bookings.unitary_cost AS UnitCost,
    Clients.first_name AS ClientFirstName,
    Clients.last_name AS ClientLastName,
    COUNT(Bookings.booking_id) AS UnitNumber,
    COUNT(Bookings.booking_id) * Bookings.unitary_cost AS TotalLine
FROM
    Purchases
JOIN
	Clients ON Purchases.client_id = Clients.client_id
JOIN
    Bookings ON Purchases.purchase_id = Bookings.purchase_id
JOIN
    Flights ON Bookings.flight_id = Flights.flight_id
GROUP BY
    Purchases.purchase_id, Flights.flight_id, Bookings.unitary_cost;
    
SELECT * FROM InvoiceHeader WHERE ClientFirstName = 'John' AND ClientLastName = 'Doe';
SELECT * FROM InvoiceDetails Where ClientFirstName = 'John' AND ClientLastName = 'Doe';


-- ----------------------------------------------------------------------------
-- Queries for the CEO questions
-- ----------------------------------------------------------------------------

-- 1. What are the top busiest routes in terms of bookings?

SELECT CONCAT(f.origin_airport, '-', f.destination_airport) AS route, origin.airport_city as Origin, destination.airport_city as Destination,COUNT(b.booking_id) AS total_bookings
FROM flights f
JOIN bookings b ON f.flight_id = b.flight_id
JOIN airports origin ON f.origin_airport = origin.airport_id
JOIN airports destination ON f.destination_airport = destination.airport_id
GROUP BY Route, origin, destination
ORDER BY total_bookings DESC
LIMIT 1;

-- 2. Which aircrafts have the highest utilization in terms of flights operated?

SELECT a.aircraft_id, a.brand as Brand, a.manufactured_year as Year, COUNT(f.flight_id) as Total_flights
FROM aircrafts a 
JOIN flights f ON a.aircraft_id = f.aircraft_id
GROUP BY a.aircraft_id, a.brand
ORDER BY Total_flights DESC
LIMIT 5;

-- 3. Which flights generated the highest revenue?

SELECT f.flight_id, CONCAT(f.origin_airport, '-', f.destination_airport) AS route, COUNT(b.booking_id) AS total_bookings,
SUM(b.unitary_cost) as total_revenue
FROM flights f 
JOIN bookings b on f.flight_id = b.flight_id
GROUP BY flight_id, route
ORDER BY total_revenue DESC;

-- 4. Which employees have worked on the most flights


SELECT CONCAT(e.first_name,' ', e.last_name) AS full_name,
COUNT(fc.flight_id) AS flights_worked
FROM employees e
JOIN flight_crew fc ON e.employee_id = fc.employee_id
GROUP BY full_name
ORDER BY flights_worked DESC;

-- 5. Which clients spent more in total, including discounts?

SELECT 
    c.first_name, 
    c.last_name, 
    SUM(total_cost * (1 - p.discount_rate) * (1 - p.tax_rate)) AS total_spent
FROM 
    Clients AS c
JOIN 
    Purchases AS p ON c.client_id = p.client_id
JOIN 
    (SELECT 
         purchase_id, 
         SUM(unitary_cost) AS total_cost
     FROM 
         Bookings
     GROUP BY 
         purchase_id
    ) AS b ON p.purchase_id = b.purchase_id
GROUP BY 
    c.client_id, c.first_name, c.last_name
ORDER BY 
    total_spent DESC;
    
-- ----------------------------------------------------------------------------
-- Testing Triggers
-- ----------------------------------------------------------------------------   

-- Trigger Check_Purchase_State: Trying to update the Purchases table without updating the Payments table
UPDATE Purchases SET state = 'Confirmed' WHERE purchase_id = 2;
--

-- Trigger Check_Booking_Capacity: 

INSERT INTO Aircrafts (brand, capacity, manufactured_year, company_id) VALUES ('Boeing2', 1, 2015,1);
INSERT INTO Flights (departure_time, arrival_time, origin_airport, destination_airport, aircraft_id) 
VALUES ('2023-12-20 10:00:00', '2023-12-20 18:00:00', 1, 2, 21);
INSERT INTO Bookings (flight_id, check_in_code, review_id, passenger_id, purchase_id, unitary_cost) 
VALUES (29, 1, 1, 1, 1, 100.00); 
INSERT INTO Bookings (flight_id, check_in_code, review_id, passenger_id, purchase_id, unitary_cost) 
VALUES (29, 1, 1, 1, 1, 100.00); 

-- Trigger Delete_bookings_on_purchase_cancel

UPDATE Purchases SET state = 'Cancelled' WHERE purchase_id = 2;

SELECT * from logs;