<?php
function getWardDetails($connection, $staff_number)
{
  return $connection->query("SELECT allocation.ward_number, ward.ward_name, ward.ward_location, ward.telephone_ext_number FROM public.allocation
    JOIN staffs.staff ON allocation.staff_number = staffs.staff.staff_number
    JOIN wards.ward ON allocation.ward_number = wards.ward.ward_number
    WHERE staff.staff_number = $staff_number;
    ")->fetch(PDO::FETCH_ASSOC);
}

?>