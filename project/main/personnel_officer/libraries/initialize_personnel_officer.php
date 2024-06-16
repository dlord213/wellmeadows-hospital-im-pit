<?php
if ($staff_position == 'Personnel Officer') {

  $ward_details = array("ward_number" => 1);

  if ($_SERVER['REQUEST_METHOD'] == "GET" && isset($_GET["ward_form"])) {
    if (isset($_GET["ward_form"]["ward_number"])) {
      $ward_details["ward_number"] = (int) $_GET["ward_form"]["ward_number"];
    }
  }


  if ($connection) {
    $wards = $connection->query("SELECT ward_number, ward_name, ward_location, telephone_ext_number FROM wards.ward")->fetchAll(PDO::FETCH_ASSOC);
  }
}
