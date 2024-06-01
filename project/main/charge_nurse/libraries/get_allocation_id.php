<?php

function getAllocationID($connection, $ward_number, $staff_number)
{
  return $connection->query("SELECT allocation_id FROM allocation
  WHERE ward_number = $ward_number AND staff_number = $staff_number;")->fetch(PDO::FETCH_ASSOC);
}

?>