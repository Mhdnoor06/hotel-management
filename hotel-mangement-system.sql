-- phpMyAdmin SQL Dump
-- version 5.1.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Feb 05, 2022 at 07:31 AM
-- Server version: 10.4.22-MariaDB
-- PHP Version: 8.0.13

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `hotel-mangement-system`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `available_room` (IN `date_in` VARCHAR(45), IN `date_out` VARCHAR(45))  BEGIN
DECLARE msg varchar(128);
IF(date_in<CURRENT_DATE) THEN
	set msg = 'Enter valid check in date.' ;
signal sqlstate '45001' set message_text = msg;
ELSEIF(date_out<=date_in) THEN
	set msg = 'Enter valid check out date.' ;
signal sqlstate '45001' set message_text = msg;
ELSE
SELECT room.room_no,room.floor_no,room_type.room_name,room_type.no_of_single_bed,room_type.no_of_double_bed,room_type.no_of_accomodate,room.features,room.amount FROM room,room_type where room.room_no IN (SELECT room_status.room_no FROM room_status  WHERE room_status.check_out IS NULL OR room_status.check_out<date_in ) AND room.room_code=room_type.room_code ;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `cancel_booked_room` (IN `roomno` INT, IN `checkout` VARCHAR(45))  BEGIN
DECLARE msg varchar(128);
if(roomno NOT IN (SELECT room_booked.room_no FROM room_booked)) THEN
   set msg = 'Enter valid room no.'; 
   signal sqlstate '45011' set message_text = msg;
ELSEif(checkout NOT IN(SELECT room_booked.check_out FROM room_booked)) THEN
   set msg = 'Enter valid check out date.'; 	
   signal sqlstate '45011' set message_text = msg;
ELSE
DELETE FROM room_booked WHERE room_booked.room_no=roomno and room_booked.check_out=checkout;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `customer_previous_booking_info_with_payment_done` (IN `id` INT)  BEGIN
SELECT room_booked.room_no,room_booked.check_in,room_booked.check_out,room_booked.total_days,room.features ,room.amount,room.features from room,room_booked where room_booked.customer_id IN (SELECT customer_id from booking WHERE booking.payment_status=1 and booking.customer_id=id) and room.room_no=room_booked.room_no and room_booked.payment_status=1;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_room_from_admin` (IN `roomno` INT)  BEGIN
DECLARE msg varchar(128);
IF(roomno ="") THEN
	set msg = 'Room no. can not be empty.' ;
signal sqlstate '45001' set message_text = msg;
ELSEIF(roomno NOT IN (SELECT room.room_no FROM room)) THEN
	set msg = 'Room does not exist.' ;
signal sqlstate '45001' set message_text = msg;
ELSE
DELETE FROM room WHERE room.room_no=roomno;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `display_customer_info_who_booked_room` (IN `id` INT)  BEGIN
SELECT customer.first_name,customer.last_name,customer.gender,customer.email,customer.contact_no,customer.nationality from customer WHERE customer.customer_id=id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_customer_id_p` (IN `name` VARCHAR(45))  BEGIN
SELECT customer.customer_id from customer where username=name;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_customer_info` (IN `id` INT)  BEGIN
SELECT customer.first_name,customer.last_name,customer.gender,customer.contact_no,customer.email FROM customer WHERE customer.customer_id=id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `payment_info` (IN `id` INT)  BEGIN
SELECT room_booked.room_no,room_booked.check_in,room_booked.check_out,room_booked.total_days,room.features ,room.amount,room.features from room,room_booked where room_booked.customer_id IN (SELECT customer_id from booking WHERE booking.payment_status=0 and booking.customer_id=id) and room.room_no=room_booked.room_no and room_booked.payment_status=0;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `room_info` (IN `code` INT)  BEGIN
DECLARE c_name VARCHAR(20);
DECLARE c_room_type CURSOR FOR SELECT room_code FROM room_type where room_code=CODE;
OPEN c_room_type;
FETCH c_room_type INTO c_name;
SELECT room_type.room_name, room.amount FROM room_type,room WHERE room_type.room_code=c_name and room.room_code=c_name;
CLOSE c_room_type;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `showing_all_customer_details_to_admin` ()  BEGIN
SELECT customer.customer_id,customer.first_name,customer.last_name,customer.gender,customer.email,customer.contact_no,customer.nationality,customer.username FROM customer;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `showing_all_room_info_to_admin` ()  BEGIN
SELECT room.room_no,room.floor_no,room_type.room_name,room_type.no_of_single_bed,room_type.no_of_double_bed,room_type.no_of_accomodate,room.features,room.amount,room.Status FROM room,room_type WHERE room.room_code=room_type.room_code;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `showing_all_room_info_to_admin_1` ()  BEGIN
SELECT room_status.status FROM room_status WHERE room.room_code=room_type.room_code;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `showing_booked_room_info_to_admin_for_payment_status_0` ()  BEGIN
SELECT room_booked.room_no,room_booked.check_in,room_booked.check_out,room_booked.customer_id
 FROM room_booked WHERE room_booked.check_out>CURRENT_DATE AND room_booked.payment_status=0;
 END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `showing_booked_room_info_to_admin_for_payment_status_1` ()  BEGIN
SELECT room_booked.room_no,room_booked.check_in,room_booked.check_out,room_booked.customer_id
 FROM room_booked WHERE room_booked.check_out>CURRENT_DATE AND room_booked.payment_status=1;
 END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `showing_customer_details_to_admin` (IN `id` INT)  BEGIN
DECLARE msg varchar(128);
IF(id ="") THEN
	set msg = 'Enter valid customer ID.' ;
signal sqlstate '45001' set message_text = msg;
ELSEIF(id NOT IN (SELECT customer.customer_id FROM customer)) THEN
	set msg = 'Enter valid customer ID.' ;
signal sqlstate '45001' set message_text = msg;
ELSE
SELECT customer.customer_id,customer.first_name,customer.last_name,customer.gender,customer.email,customer.contact_no,customer.nationality,customer.username FROM customer where customer.customer_id=id;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `show_all_employee_to_admin` ()  BEGIN
SELECT employee.employee_id,employee.first_name,employee.last_name,employee.gender,employee.department,employee.contact_no,employee.salary FROM employee;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `show_attendence_of_employee` (IN `date` VARCHAR(45))  BEGIN
DECLARE msg varchar(128);
IF(date NOT IN (SELECT employee_attendence.date FROM employee_attendence)) THEN
	set msg = 'Enter valid date' ;
signal sqlstate '45001' set message_text = msg;
ELSE
SELECT employee_attendence.employee_id,employee.first_name,employee.last_name,employee.department FROM employee_attendence,employee WHERE employee_attendence.date=date AND employee.employee_id=employee_attendence.employee_id;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `update_customer_info` (IN `f_name` VARCHAR(45), IN `l_name` VARCHAR(45), IN `g` VARCHAR(45), IN `em` VARCHAR(45), IN `contact` INT, IN `nationality` VARCHAR(45), IN `user` VARCHAR(45))  BEGIN
UPDATE customer SET customer.first_name=f_name,customer.last_name=l_name,customer.gender=g,customer.email=em,customer.contact_no=contact,customer.nationality=nationality WHERE customer.username=user;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `update_room_info_by_admin` (IN `roomno` INT, IN `floorno` INT, IN `roomname` VARCHAR(45), IN `features` VARCHAR(45), IN `price` INT)  BEGIN
DECLARE msg varchar(128);
IF(roomno NOT IN (SELECT room.room_no FROM room)) THEN
	set msg = 'Enter valid room no.' ;
signal sqlstate '45001' set message_text = msg;
elseIF(roomname NOT IN (SELECT room_type.room_name FROM room_type)) THEN
	set msg = 'Enter valid room name.' ;
signal sqlstate '45001' set message_text = msg;
elseIF(floorno="") THEN
	set msg = 'Floor no can not be null.' ;
signal sqlstate '45001' set message_text = msg;
elseIF(price="") THEN
	set msg = 'Price can not be null.' ;
signal sqlstate '45001' set message_text = msg;
ELSE
UPDATE room SET room.floor_no=floorno,room.features=features,room.amount=price,room.room_code=(SELECT room_type.room_code FROM room_type WHERE room_type.room_name=roomname) WHERE room.room_no=roomno;
END IF;
END$$

--
-- Functions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `get_customer_id` (`name` VARCHAR(45)) RETURNS INT(11) BEGIN
DECLARE id int;
SELECT customer.customer_id from customer where username=name into id;
RETURN id;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `booking`
--

CREATE TABLE `booking` (
  `booking_id` int(11) NOT NULL,
  `customer_id` int(11) NOT NULL,
  `no_of_room` int(11) NOT NULL,
  `amount` int(11) NOT NULL,
  `payment_status` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `booking`
--

INSERT INTO `booking` (`booking_id`, `customer_id`, `no_of_room`, `amount`, `payment_status`) VALUES
(51, 60, 1, 20000, 1),
(52, 61, 0, 13003, 1),
(53, 59, 2, 55000, 1),
(54, 58, 1, 30000, 1),
(55, 62, 1, 61996, 1),
(56, 63, -2, -106995, 1),
(57, 64, 1, 44997, 0),
(58, 62, 1, -6000, 1),
(59, 62, 1, -6000, 1),
(60, 62, 1, -6000, 1),
(61, 63, -2, -38999, 1),
(62, 63, -2, -53998, 1),
(63, 65, 1, 29998, 1),
(64, 63, -1, -32000, 1),
(65, 62, 1, 13998, 0),
(67, 63, -1, -9001, 1),
(68, 63, -1, -24000, 1),
(69, 63, -1, -24000, 1),
(70, 63, 2, 20997, 1);

-- --------------------------------------------------------

--
-- Table structure for table `customer`
--

CREATE TABLE `customer` (
  `customer_id` int(11) NOT NULL,
  `first_name` varchar(45) NOT NULL,
  `last_name` varchar(45) NOT NULL,
  `gender` varchar(45) NOT NULL,
  `email` varchar(45) NOT NULL,
  `contact_no` int(11) NOT NULL,
  `nationality` varchar(45) NOT NULL,
  `username` varchar(45) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `customer`
--

INSERT INTO `customer` (`customer_id`, `first_name`, `last_name`, `gender`, `email`, `contact_no`, `nationality`, `username`) VALUES
(58, 'nirav', 'patel', 'male', 'harsh.p5@ahduni.edu.in', 2147483647, 'indian', 'nirav'),
(59, 'harsh', 'patel', 'male', 'harshpatel.hp908@gmail.com', 2147483647, 'non_indian', 'harsh'),
(60, 'Raj', 'Patel', 'male', 'raj@gmail.com', 2147483647, 'non_indian', 'raj'),
(61, 'Tirth', 'Kanani', 'male', 'tirth.k@gmail.com', 2147483647, 'indian', 'tirth'),
(62, 'noor', 'mohammed', 'male', 'mn@hmail.com', 2147483647, 'indian', 'noor'),
(63, 'md', 'maqsood', 'male', 'mdmaqsood@gmail.com', 2147483647, 'indian', 'maqsood'),
(64, 'noo', 'oor', 'male', 'mhnoor@gmail.com', 2147483647, 'indian', 'noor1'),
(65, 'abc', 'aaa', 'male', 'abx@gmail.com', 2147483647, 'indian', 'zayaan');

--
-- Triggers `customer`
--
DELIMITER $$
CREATE TRIGGER `chk_all_customer_info_is_non_empty` BEFORE INSERT ON `customer` FOR EACH ROW BEGIN
DECLARE msg varchar(128);
if(new.first_name="") THEN
   set msg = 'Error: First name can not be null.'; 
   signal sqlstate '45003' set message_text = msg;
end if;
IF(new.last_name ="") THEN
set msg = 'Error: Last name can not be null.'; 
   signal sqlstate '45004' set message_text = msg;  
end if;
IF(new.contact_no ="") THEN
set msg = 'Error: Contact no can not be null.'; 
   signal sqlstate '45005' set message_text = msg;  
end if;
IF(SELECT length(new.contact_no)<>10) THEN
set msg = 'Error: Please enter valid contact no.'; 
   signal sqlstate '45005' set message_text = msg;  
end if;
IF(new.email ="") THEN
set msg = 'Error: email can not be null.'; 
   signal sqlstate '45007' set message_text = msg;  
end if;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `chk_all_customer_info_is_non_empty_before_update` BEFORE UPDATE ON `customer` FOR EACH ROW BEGIN
DECLARE msg varchar(128);
if(new.first_name="") THEN
   set msg = 'Error: First name can not be null.'; 
   signal sqlstate '45003' set message_text = msg;
end if;
IF(new.last_name ="") THEN
set msg = 'Error: Last name can not be null.'; 
   signal sqlstate '45004' set message_text = msg;  
end if;
IF(new.contact_no ="") THEN
set msg = 'Error: Contact no can not be null.'; 
   signal sqlstate '45005' set message_text = msg;  
end if;
IF(SELECT length(new.contact_no)<>10) THEN
set msg = 'Error: Please enter valid contact no.'; 
   signal sqlstate '45005' set message_text = msg;  
end if;
IF(new.email ="") THEN
set msg = 'Error: email can not be null.'; 
   signal sqlstate '45007' set message_text = msg;  
end if;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `room`
--

CREATE TABLE `room` (
  `room_no` int(11) NOT NULL,
  `floor_no` int(11) NOT NULL,
  `room_code` int(11) NOT NULL,
  `features` varchar(90) DEFAULT NULL,
  `amount` int(11) NOT NULL,
  `Status` varchar(10) NOT NULL DEFAULT 'Not booked'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `room`
--

INSERT INTO `room` (`room_no`, `floor_no`, `room_code`, `features`, `amount`, `Status`) VALUES
(101, 1, 111, 'Free Wifi - 1 king bed - Shower and bathtub', 6999, 'booked'),
(102, 1, 111, 'Free Wifi - 1 king bed - Shower and bathtub', 6999, 'booked'),
(103, 1, 111, 'Free Wifi - 1 king bed - Shower and bathtub', 6999, 'unbooked'),
(104, 1, 222, 'Free Wifi -Single bed -1 king bed - Shower and bathtub -Additional toilet', 8999, 'unbooked'),
(105, 1, 222, 'Free Wifi -Single bed -1 king bed - Shower and bathtub -Additional toilet', 8999, 'unbooked'),
(201, 2, 111, 'Free Wifi - 1 king bed - Shower and bathtub', 6999, 'booked'),
(202, 2, 111, 'Free Wifi - 1 king bed - Shower and bathtub', 6999, 'booked'),
(203, 2, 222, 'Free Wifi -Single bed -1 king bed - Shower and bathtub -Additional toilet', 8999, 'unbooked'),
(204, 2, 222, 'Free Wifi -Single bed -1 king bed - Shower and bathtub -Additional toilet', 8999, 'unbooked'),
(205, 2, 222, 'Free Wifi -2 king beds -Swimming Pool Access -Executive Lounge Access', 12999, 'unbooked'),
(301, 3, 333, 'Free Wifi -2 king beds -Swimming Pool Access with city/pool view -Executive Lounge Access', 14999, 'unbooked'),
(302, 3, 333, 'Free Wifi -2 king beds -Swimming Pool Access with city/pool view -Executive Lounge Access', 14999, 'unbooked'),
(303, 3, 333, 'Free Wifi -2 king beds -Swimming Pool Access with city/pool view -Executive Lounge Access', 14999, 'booked'),
(304, 3, 333, 'Free Wifi -2 king beds -Swimming Pool Access with city/pool view -Executive Lounge Access', 14999, 'unbooked');

--
-- Triggers `room`
--
DELIMITER $$
CREATE TRIGGER `add_room_details_to_room_status` AFTER INSERT ON `room` FOR EACH ROW BEGIN
INSERT INTO room_status VALUES (new.room_no,"");
End
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `chk_room_details_by_admin` BEFORE INSERT ON `room` FOR EACH ROW BEGIN
DECLARE msg varchar(128);
IF(new.room_no IN (SELECT room.room_no FROM room)) THEN
	set msg = 'Room no already exist.' ;
signal sqlstate '45001' set message_text = msg;
END IF;
IF(new.room_no ="") THEN
	set msg = 'Room no can not be empty.' ;
signal sqlstate '45001' set message_text = msg;
END IF;
IF(new.floor_no="") THEN
	set msg = 'Floor no can not be empty.' ;
signal sqlstate '45001' set message_text = msg;
END IF;
IF(new.amount="") THEN
	set msg = 'Price can not be empty.' ;
signal sqlstate '45001' set message_text = msg;
END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `delete_room_from_room_status` BEFORE DELETE ON `room` FOR EACH ROW BEGIN
DELETE FROM room_status where old.room_no=room_status.room_no;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `update_status` BEFORE INSERT ON `room` FOR EACH ROW update room set Status='Booked' where room_booked.room_no=room.room_no
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `room_booked`
--

CREATE TABLE `room_booked` (
  `customer_id` int(11) NOT NULL,
  `check_in` date NOT NULL,
  `check_out` date NOT NULL,
  `total_days` int(11) NOT NULL,
  `room_no` int(11) NOT NULL,
  `payment_status` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `room_booked`
--

INSERT INTO `room_booked` (`customer_id`, `check_in`, `check_out`, `total_days`, `room_no`, `payment_status`) VALUES
(60, '2021-04-11', '2021-04-13', 2, 101, 1),
(58, '2021-04-11', '2021-04-14', 3, 104, 1),
(59, '2021-04-11', '2021-04-13', 2, 204, 1),
(59, '2021-04-12', '2021-04-13', 1, 302, 1),
(62, '2021-12-25', '2021-12-30', 5, 301, 1),
(64, '2021-12-30', '2022-01-02', 3, 304, 0),
(62, '2022-01-20', '2022-01-21', 1, 101, 1),
(63, '2022-01-20', '2022-01-21', 1, 102, 1),
(62, '2022-01-21', '2022-01-22', 1, 103, 1),
(62, '2022-01-21', '2022-01-22', 1, 202, 1),
(63, '2022-01-21', '2022-01-25', 4, 301, 1),
(65, '2022-02-02', '2022-02-04', 2, 303, 1),
(62, '2022-02-04', '2022-02-06', 2, 101, 0),
(63, '2022-02-04', '2022-02-06', 2, 102, 1),
(63, '2022-02-05', '2022-02-06', 1, 201, 1),
(63, '2022-02-06', '2022-02-08', 2, 202, 1);

--
-- Triggers `room_booked`
--
DELIMITER $$
CREATE TRIGGER `check_room_no` BEFORE INSERT ON `room_booked` FOR EACH ROW BEGIN
DECLARE msg varchar(128);
IF(new.room_no IN (SELECT room_status.room_no from room_status where room_status.check_out>new.check_in AND room_status.room_no=new.room_no)) THEN
   set msg = 'Room already booked for this check in date'; 
   signal sqlstate '45001' set message_text = msg; 
end if;
IF(new.room_no NOT IN (SELECT room.room_no FROM room)) THEN
   set msg = 'Enter valid room no.'; 
   signal sqlstate '45001' set message_text = msg; 
end if;
IF(new.check_in<CURRENT_DATE) THEN
	set msg = 'Enter valid check in date bsdk.' ;
signal sqlstate '45001' set message_text = msg;
end if;
IF(new.check_out<=new.check_in) THEN
	set msg = 'Enter valid check out date.' ;
signal sqlstate '45001' set message_text = msg;
end if;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `delete_checkout_room_status` AFTER DELETE ON `room_booked` FOR EACH ROW BEGIN 
UPDATE room_status SET room_status.check_out=(SELECT MAX(room_booked.check_out) from room_booked where room_booked.room_no=old.room_no) where room_status.room_no=old.room_no;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `update_booking_entry_after_deleting_room_booked` BEFORE DELETE ON `room_booked` FOR EACH ROW BEGIN
UPDATE booking SET booking.no_of_room=booking.no_of_room-1,booking.amount=booking.amount-(SELECT total_days FROM room_booked WHERE room_booked.room_no=old.room_no and room_booked.check_out=old.check_out)*(SELECT amount from room WHERE old.room_no=room.room_no) WHERE old.customer_id=booking.customer_id;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `update_booking_table` AFTER INSERT ON `room_booked` FOR EACH ROW BEGIN
IF(new.customer_id IN (SELECT booking.customer_id FROM booking where booking.payment_status=0)) THEN
UPDATE booking SET booking.no_of_room=booking.no_of_room+1,
booking.amount=booking.amount+(SELECT total_days FROM room_booked WHERE room_booked.room_no=new.room_no AND room_booked.check_out=new.check_out)*(SELECT room.amount from room WHERE room.room_no=new.room_no) WHERE new.customer_id=booking.customer_id;
ELSEIF(new.customer_id IN (SELECT booking.customer_id FROM booking where booking.payment_status=1)) THEN
INSERT INTO booking (customer_id,no_of_room,amount,payment_status) VALUES(new.customer_id,1,(SELECT total_days FROM room_booked WHERE room_booked.room_no=new.room_no AND room_booked.check_out=new.check_out)*(SELECT room.amount from room WHERE room.room_no=new.room_no),0);
ELSE
INSERT INTO booking (customer_id,no_of_room,amount,payment_status) VALUES(new.customer_id,1,(SELECT total_days FROM room_booked WHERE room_booked.room_no=new.room_no AND room_booked.check_out=new.check_out)*(SELECT room.amount from room WHERE room.room_no=new.room_no),0);
END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `update_room_status` AFTER INSERT ON `room_booked` FOR EACH ROW BEGIN
update room_status set room_status.check_out=new.check_out WHERE new.room_no=room_status.room_no;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `room_status`
--

CREATE TABLE `room_status` (
  `room_no` int(11) NOT NULL,
  `check_out` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `room_status`
--

INSERT INTO `room_status` (`room_no`, `check_out`) VALUES
(101, '2022-02-06'),
(102, '2022-02-06'),
(103, '2022-01-22'),
(104, '2021-04-14'),
(105, '0000-00-00'),
(201, '2022-02-06'),
(202, '2022-02-08'),
(203, '0000-00-00'),
(204, '2021-04-13'),
(205, '0000-00-00'),
(301, '2022-01-25'),
(302, '2021-04-13'),
(303, '2022-02-04'),
(304, '2022-01-02');

-- --------------------------------------------------------

--
-- Table structure for table `room_type`
--

CREATE TABLE `room_type` (
  `room_code` int(11) NOT NULL,
  `room_name` varchar(45) NOT NULL,
  `no_of_single_bed` int(11) DEFAULT NULL,
  `no_of_double_bed` int(11) DEFAULT NULL,
  `no_of_accomodate` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `room_type`
--

INSERT INTO `room_type` (`room_code`, `room_name`, `no_of_single_bed`, `no_of_double_bed`, `no_of_accomodate`) VALUES
(111, 'Delux', 0, 1, 2),
(222, 'Super Delux', 1, 1, 3),
(333, 'Luxury', 2, 2, 4);

-- --------------------------------------------------------

--
-- Table structure for table `transaction`
--

CREATE TABLE `transaction` (
  `transaction_id` int(11) NOT NULL,
  `booking_id` int(11) NOT NULL,
  `payment_type` varchar(45) NOT NULL,
  `total_amount` int(11) NOT NULL,
  `payment_date` date NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `transaction`
--

INSERT INTO `transaction` (`transaction_id`, `booking_id`, `payment_type`, `total_amount`, `payment_date`) VALUES
(48, 51, 'DEBIT_CARD', 20000, '2021-04-11'),
(49, 52, 'CREID_CARD', 42000, '2021-04-11'),
(50, 53, 'NET_BANKING', 55000, '2021-04-11'),
(51, 54, 'UPI', 30000, '2021-04-11'),
(52, 55, 'DEBIT_CARD', 74995, '2021-12-26'),
(66, 56, 'CASH', 6999, '2022-01-20'),
(67, 58, 'CASH', 6999, '2022-01-20'),
(71, 59, 'CASH', 6999, '2022-01-20'),
(72, 60, 'CASH', 6999, '2022-01-20'),
(73, 61, 'CREID_CARD', 74995, '2022-01-20'),
(74, 62, 'NET_BANKING', 59996, '2022-01-21'),
(75, 63, 'NET_BANKING', 29998, '2022-02-02'),
(76, 64, 'UPI', 6999, '2022-02-04'),
(77, 67, 'NET_BANKING', 29998, '2022-02-04'),
(78, 68, 'NET_BANKING', 14999, '2022-02-04'),
(79, 69, 'NET_BANKING', -37998, '2022-02-04'),
(80, 70, 'CASH', 20997, '2022-02-04');

--
-- Triggers `transaction`
--
DELIMITER $$
CREATE TRIGGER `update_payment_status_in_booking` BEFORE INSERT ON `transaction` FOR EACH ROW BEGIN
UPDATE booking set booking.payment_status=1 WHERE
booking.booking_id=new.booking_id;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `update_payment_status_in_room_booked` BEFORE INSERT ON `transaction` FOR EACH ROW BEGIN
UPDATE room_booked set room_booked.payment_status=1 WHERE
room_booked.customer_id IN(SELECT booking.customer_id from booking where booking.booking_id=new.booking_id);
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `username` varchar(45) NOT NULL,
  `password` varchar(100) NOT NULL,
  `created_at` date NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `username`, `password`, `created_at`) VALUES
(12, 'harsh', '$2y$10$n9HfupQGPfoqO98KST98z.ivFc3hXFlQOgJ8s5GairNsYf1pPR5J.', '2021-04-09'),
(13, 'nirav', '$2y$10$CHRnraW4ozk.F5hTz.NXf.OY7rG6qdeN8lG1QkekRgIb8ocWrl/WG', '2021-04-09'),
(14, 'raj', '$2y$10$yM9JQB2J1Vm24OAAvYa0lO/sz4iZCaSAJw9UmxMV4BwUTFOvDTCvK', '2021-04-11'),
(15, 'tirth', '$2y$10$X9foavhGhXOL.SMFCG5UDuD6.2bMhRVfEejxmerhiiQihupOes9Mi', '2021-04-11'),
(16, 'ankit', '$2y$10$f06syfU7YKr4E2TmgkOxxOrGG4.zHKN7/tA7zx2e5TPYWZz3glu6a', '2021-04-11'),
(17, 'noor', '$2y$10$fI./z7C43RxsmKD9StedIu/q/apw2NOeRHfocpQHwyXD14RDHPUNG', '2021-12-25'),
(18, 'admin', '$2y$10$ima15KT/Ep8AUfl32aiY0.WWiK7/J5oQJUJWvnDxFhJF7ar9PrQpy', '2021-12-25'),
(19, 'maqsood', '$2y$10$pB7Aeb38CKxoPWkx9pw5du4F05pYXbBw0F9WMjLmAddJMqAhMMhWG', '2021-12-25'),
(20, 'noor1', '$2y$10$6BPb3V8k3ujda.hlsTjwKO1ZbIAuWyeiNvAy/djdKB2V7NLOLpPJu', '2021-12-30'),
(21, 'zayaan', '$2y$10$pImNs7/OlQ6e/3FAX79pfelAONjWHIzUH2ugcHNhzk3BSEWoMk1KO', '2022-02-01');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `booking`
--
ALTER TABLE `booking`
  ADD PRIMARY KEY (`booking_id`),
  ADD KEY `fk_customer_id` (`customer_id`);

--
-- Indexes for table `customer`
--
ALTER TABLE `customer`
  ADD PRIMARY KEY (`customer_id`),
  ADD KEY `username` (`username`);

--
-- Indexes for table `room`
--
ALTER TABLE `room`
  ADD PRIMARY KEY (`room_no`),
  ADD KEY `fk_room_code` (`room_code`);

--
-- Indexes for table `room_booked`
--
ALTER TABLE `room_booked`
  ADD PRIMARY KEY (`check_in`,`room_no`),
  ADD KEY `cust_fk` (`customer_id`),
  ADD KEY `room_no_fk` (`room_no`);

--
-- Indexes for table `room_status`
--
ALTER TABLE `room_status`
  ADD PRIMARY KEY (`room_no`,`check_out`);

--
-- Indexes for table `room_type`
--
ALTER TABLE `room_type`
  ADD PRIMARY KEY (`room_code`);

--
-- Indexes for table `transaction`
--
ALTER TABLE `transaction`
  ADD PRIMARY KEY (`transaction_id`),
  ADD KEY `fk_bookingid` (`booking_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `booking`
--
ALTER TABLE `booking`
  MODIFY `booking_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=71;

--
-- AUTO_INCREMENT for table `customer`
--
ALTER TABLE `customer`
  MODIFY `customer_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=66;

--
-- AUTO_INCREMENT for table `transaction`
--
ALTER TABLE `transaction`
  MODIFY `transaction_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=81;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `booking`
--
ALTER TABLE `booking`
  ADD CONSTRAINT `fk_customer_id` FOREIGN KEY (`customer_id`) REFERENCES `customer` (`customer_id`);

--
-- Constraints for table `customer`
--
ALTER TABLE `customer`
  ADD CONSTRAINT `fk_username` FOREIGN KEY (`username`) REFERENCES `users` (`username`);

--
-- Constraints for table `room`
--
ALTER TABLE `room`
  ADD CONSTRAINT `fk_room_code` FOREIGN KEY (`room_code`) REFERENCES `room_type` (`room_code`);

--
-- Constraints for table `room_booked`
--
ALTER TABLE `room_booked`
  ADD CONSTRAINT `cust_fk` FOREIGN KEY (`customer_id`) REFERENCES `customer` (`customer_id`),
  ADD CONSTRAINT `room_no_fk` FOREIGN KEY (`room_no`) REFERENCES `room` (`room_no`);

--
-- Constraints for table `room_status`
--
ALTER TABLE `room_status`
  ADD CONSTRAINT `fk_room_no` FOREIGN KEY (`room_no`) REFERENCES `room` (`room_no`);

--
-- Constraints for table `transaction`
--
ALTER TABLE `transaction`
  ADD CONSTRAINT `fk_bookingid` FOREIGN KEY (`booking_id`) REFERENCES `booking` (`booking_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
