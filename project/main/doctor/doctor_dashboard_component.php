<!-- Patients -->
<div class="hidden md:flex flex-row justify-between my-2 items-end">
  <h1 class="text-xl text-slate-700 font-[700]">Patients handled by <?php echo $doctor_fullname; ?></h1>
</div>
<div class="hidden md:grid grid-cols-5 bg-slate-200 p-4 rounded-lg">
  <?php
  $patients = $connection->query("SELECT patient_number, firstname || ' ' || lastname AS patient_name, date_of_birth, telephone_number, date_registered
      FROM patients.patient
      WHERE doctor_id = " . $doctor_id)->fetchAll(PDO::FETCH_ASSOC);

  if (count($patients) == 0) {
    echo "<h1 class='font-[400] text-slate-600 text-xl col-span-5'>No inpatients on ward " . $ward_details['ward_number'] . ".</h1>";
  } else {
    echo "<h1 class='font-[700] text-slate-600'>Patient Number</h1>
    <h1 class='font-[700] text-slate-600'>Patient Name</h1>
    <h1 class='font-[700] text-slate-600'>Date Of Birth</h1>
    <h1 class='font-[700] text-slate-600'>Telephone Number</h1>
    <h1 class='font-[700] text-slate-600'>Date Registered</h1>";
    foreach ($patients as $patient) {
      echo "
            <p class='text-slate-700'>" . $patient['patient_number'] . "</p>
            <p class='text-slate-700'>" . $patient['patient_name'] . "</p>
            <p class='text-slate-700'>" . $patient['date_of_birth'] . "</p>
            <p class='text-slate-700'>" . $patient['telephone_number'] . "</p>
            <p class='text-slate-700'>" . $patient['date_registered'] . "</p>
          ";
    }
  }
  ?>
</div>