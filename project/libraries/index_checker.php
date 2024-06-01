<?php
if (isset($_SESSION['staff_name']) && isset($_SESSION['staff_position']) && isset($_SESSION['staff_number'])) {
  header('Location: ./main/index.php');
  exit();
}
?>