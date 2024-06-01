<?php
if ($staff_position == 'Medical Director') {

  $ward_details = array("ward_number" => 1);

  $inpatient_number = 1;

  if ($_SERVER['REQUEST_METHOD'] == "GET" && isset($_GET["ward_form"])) {
    if (isset($_GET["ward_form"]["ward_number"])) {
      $ward_details["ward_number"] = (int) $_GET["ward_form"]["ward_number"];
    }
  }
  if ($_SERVER['REQUEST_METHOD'] == "GET" && isset($_GET["inpatient_form"])) {
    if (isset($_GET["inpatient_form"]["inpatient_number"])) {
      $inpatient_number = (int) $_GET["inpatient_form"]["inpatient_number"];
    }
  }


  if ($connection) {
    $wards = $connection->query("SELECT ward_number, ward_name, ward_location, telephone_ext_number FROM wards.ward")->fetchAll(PDO::FETCH_ASSOC);

    $patients_medications = $connection->query("SELECT DISTINCT medication.bed_number, patient.firstname || ' ' || patient.lastname AS patient_name FROM medication
    JOIN inpatient ON medication.bed_number = inpatient.bed_number
    JOIN appointment ON inpatient.appointment_number = appointment.appointment_number
    JOIN patients.patient ON appointment.patient_number = patient.patient_number")->fetchAll(PDO::FETCH_ASSOC);

    $patient_medication_details = getPatientMedication($connection, $inpatient_number);

  }
}
?>