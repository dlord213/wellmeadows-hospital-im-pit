<?php
function getWardDetails($connection, $ward_number)
{
  return $connection->query("SELECT allocation.ward_number, ward.ward_name, ward.ward_location, ward.telephone_ext_number FROM public.allocation
    JOIN wards.ward ON allocation.ward_number = wards.ward.ward_number
    WHERE wards.ward.ward_number = $ward_number
    LIMIT 1;
    ")->fetch(PDO::FETCH_ASSOC);
}
