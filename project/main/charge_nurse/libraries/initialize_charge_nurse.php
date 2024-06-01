<?php
if ($connection) {
  if ($staff_position == 'Charge Nurse') {
    $ward_details = getWardDetails($connection, $staff_number);
  }
}
?>