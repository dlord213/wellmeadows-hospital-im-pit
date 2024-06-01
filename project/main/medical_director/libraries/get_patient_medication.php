<?php

function getPatientMedication($connection, $bed_number)
{
  return $connection->query("SELECT patient.patient_number, patient.firstname || ' ' || patient.lastname AS patient_name, 
    ward.ward_number, ward.ward_name, medication.bed_number, drug.drug_number, drug.drug_name,
    drug.description, drug.dosage, drug.method_of_admin, medication.starting_date, medication.finished_date
    FROM medication
    JOIN inpatient ON medication.bed_number = inpatient.bed_number
    JOIN allocation ON inpatient.allocation_id = allocation.allocation_id
    JOIN appointment ON inpatient.appointment_number = appointment.appointment_number
    JOIN patients.patient ON appointment.patient_number = patient.patient_number
    JOIN wards.ward ON allocation.ward_number = ward.ward_number
    JOIN drug ON medication.drug_number = drug.drug_number
    WHERE medication.bed_number = $bed_number
")->fetchAll(PDO::FETCH_ASSOC);
}

?>