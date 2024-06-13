<?php
session_start();
require '../libraries/connect_to_database.php';

$staff_number = $_SESSION['staff_number'];
$staff_name = $_SESSION['staff_name'];
$staff_position = $_SESSION['staff_position'];

$connection = connectToDatabase($staff_position);
