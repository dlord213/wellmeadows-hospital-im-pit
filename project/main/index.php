<?php

session_start();
require './libraries/checker.php';
require './libraries/connect_to_database.php';

if (!isset($_SESSION['staff_number'])) {
  $staff_position = $_SESSION['staff_position'];
  $doctor_id = $_SESSION['doctor_id'];
  $doctor_fullname = $_SESSION['doctor_fullname'];
  $doctor_address = $_SESSION['doctor_address'];
  $doctor_tel_number = $_SESSION['doctor_tel_number'];
} else {
  $staff_position = $_SESSION['staff_position'];
  $staff_number = $_SESSION['staff_number'];
  $staff_name = $_SESSION['staff_name'];
}

$connection = connectToDatabase($staff_position);

if ($staff_position == 'Charge Nurse') {
  require './charge_nurse/libraries/get_ward_details.php';
  require './charge_nurse/libraries/initialize_charge_nurse.php';
} elseif ($staff_position == 'Medical Director') {
  require './medical_director/libraries/get_patient_medication.php';
  require './medical_director/libraries/initialize_medical_director.php';
}

if (!in_array($staff_position, ['Doctor', 'Medical Director', 'Charge Nurse'])) {
  $ward_details = $connection->query("SELECT ward.ward_number, ward_name FROM allocation 
    JOIN wards.ward ON allocation.ward_number = wards.ward.ward_number
    WHERE staff_number = " . $_SESSION['staff_number'])->fetch(PDO::FETCH_ASSOC);
}

?>

<!DOCTYPE html>
<html lang="en">

<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Hospital | Dashboard</title>
  <?php include './../libraries/header_scripts.php' ?>
</head>

<body class="bg-slate-100">
  <?php require './components/header_component.php' ?>
  <main class="max-w-7xl w-full xl:mx-auto xl:mt-4 xl:p-0 p-4">
    <?php
    switch ($staff_position) {
      case 'Charge Nurse':
        require './charge_nurse/charge_nurse_dashboard_component.php';
        break;
      case 'Medical Director':
        require './medical_director/medical_director_dashboard_component.php';
        break;
      case 'Doctor':
        require './doctor/doctor_dashboard_component.php';
        break;
      default:
        require './staff/staff_dashboard_component.php';
        break;
    }
    ?>
  </main>

</body>

</html>