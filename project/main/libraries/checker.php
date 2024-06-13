<?php

if (!isset($_SESSION['staff_number']) && !isset($_SESSION['doctor_id']) && !isset($_SESSION['doctor_fullname'])) {
  header('Location: ../.././index.php');
  exit();
}
