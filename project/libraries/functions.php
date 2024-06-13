<?php
function getStaffDetails($connection, $username, $password)
{
  $sql = "SELECT staff.staff_number, staff.firstname || ' ' || staff.lastname AS staff_name, staff.staff_position 
          FROM users.staff_user
          JOIN staffs.staff ON users.staff_user.staff_number = staffs.staff.staff_number
          WHERE username = :username AND _password = :password";
  $stmt = $connection->prepare($sql);
  $stmt->execute(['username' => $username, 'password' => $password]);
  return $stmt->fetch(PDO::FETCH_ASSOC);
}

function getDoctorDetails($connection, $username, $password)
{
  $sql = "SELECT doctor.doctor_id, doctor.fullname, doctor.address, doctor.telephone_number
          FROM users.staff_user
          JOIN patients.doctor ON users.staff_user.doctor_id = doctor.doctor_id
          WHERE username = :username AND _password = :password";
  $stmt = $connection->prepare($sql);
  $stmt->execute(['username' => $username, 'password' => $password]);
  return $stmt->fetch(PDO::FETCH_ASSOC);
}

function setSession($details, $position = null)
{
  if ($position === 'Doctor') {
    $_SESSION['staff_position'] = 'Doctor';
    $_SESSION['doctor_id'] = $details['doctor_id'];
    $_SESSION['doctor_fullname'] = $details['fullname'];
    $_SESSION['doctor_address'] = $details['address'];
    $_SESSION['doctor_tel_number'] = $details['telephone_number'];
  } else {
    $_SESSION['staff_number'] = $details['staff_number'];
    $_SESSION['staff_name'] = $details['staff_name'];
    $_SESSION['staff_position'] = $details['staff_position'];
  }
}
