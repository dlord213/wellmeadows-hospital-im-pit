<!-- Patients -->
<div class="hidden md:flex flex-row justify-between my-2 items-end">
  <h1 class="text-xl text-slate-700 font-[700]">Patients handled by <?php echo $doctor_fullname; ?></h1>
</div>
<div class="hidden md:grid grid-cols-5 bg-slate-200 p-4 rounded-lg">
  <?php
  $doctor_id = intval($doctor_id);

  $patients = $connection->query(
    "SELECT patient_number, 
            firstname || ' ' || lastname AS patient_name, 
            date_of_birth, 
            telephone_number, 
            date_registered
     FROM patients.patient
     WHERE doctor_id = $doctor_id"
  )->fetchAll(PDO::FETCH_ASSOC);
  ?>

  <?php if (count($patients) == 0) : ?>
    <h1 class="font-[400] text-slate-600 text-xl col-span-5">
      No patients for doctor <?= htmlspecialchars($doctor_id) ?>.
    </h1>
  <?php else : ?>
    <h1 class="font-[700] text-slate-600">Patient Number</h1>
    <h1 class="font-[700] text-slate-600">Patient Name</h1>
    <h1 class="font-[700] text-slate-600">Date Of Birth</h1>
    <h1 class="font-[700] text-slate-600">Telephone Number</h1>
    <h1 class="font-[700] text-slate-600">Date Registered</h1>
    <?php foreach ($patients as $patient) : ?>
      <p class="text-slate-700"><?= htmlspecialchars($patient['patient_number']) ?></p>
      <p class="text-slate-700"><?= htmlspecialchars($patient['patient_name']) ?></p>
      <p class="text-slate-700"><?= htmlspecialchars($patient['date_of_birth']) ?></p>
      <p class="text-slate-700"><?= htmlspecialchars($patient['telephone_number']) ?></p>
      <p class="text-slate-700"><?= htmlspecialchars($patient['date_registered']) ?></p>
    <?php endforeach; ?>
  <?php endif; ?>
</div>