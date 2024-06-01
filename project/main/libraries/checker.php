<?php

if (!isset($_SESSION['staff_number']) && !isset($_SESSION['doctor_id']) && !isset($_SESSION['doctor_fullname'])) {
  // Redirect to the index page if neither staff_number nor doctor_id and doctor_fullname are set
  header('Location: ../.././index.php');
  exit();
}


?>