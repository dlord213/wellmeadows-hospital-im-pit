<?php

function connectToDatabase($staff_position)
{
  $dbname = "wellmeadows_hospital_pit";

  if ($staff_position == "Charge Nurse") {
    $username = "charge_nurse";
    $password = "nurse";
  } elseif ($staff_position == "Medical Director") {
    $username = "medical_director";
    $password = "medical_director";
  } elseif ($staff_position == 'Doctor') {
    $username = "doctor";
    $password = "doctor";
  }

  try {
    return new PDO("pgsql:host=localhost;dbname=$dbname", $username, $password);
  } catch (PDOException $e) {
    die($e->getMessage());
  }

}
?>