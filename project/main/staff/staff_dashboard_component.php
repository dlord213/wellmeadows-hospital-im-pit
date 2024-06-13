<!-- Ward -->
<div class="hidden md:flex flex-row justify-between my-2 items-end">
  <h1 class="text-xl text-slate-700 font-[700]">Staffs on Ward <?php echo $ward_details['ward_number']; ?></h1>
</div>
<div class="hidden md:grid grid-cols-4 bg-slate-200 p-4 rounded-lg">
  <h1 class='font-[700] text-slate-600'>Staff Number</h1>
  <h1 class='font-[700] text-slate-600'>Staff Name</h1>
  <h1 class='font-[700] text-slate-600'>Staff Position</h1>
  <h1 class='font-[700] text-slate-600'>Shift</h1>
  <?php
  $ward_number = intval($ward_details['ward_number']); // Ensure the ward number is an integer to prevent SQL injection

  $staffs = $connection->query(
    "SELECT DISTINCT staff.staff_number, 
            staff.firstname || ' ' || staff.lastname AS staff_name, 
            staff.staff_position, 
            allocation.shift 
     FROM allocation
     JOIN staffs.staff ON allocation.staff_number = staffs.staff.staff_number
     WHERE ward_number = $ward_number"
  )->fetchAll(PDO::FETCH_ASSOC);
  ?>
  <?php foreach ($staffs as $staff) : ?>
    <p class="text-slate-700"><?= htmlspecialchars($staff['staff_number']) ?></p>
    <p class="text-slate-700"><?= htmlspecialchars($staff['staff_name']) ?></p>
    <p class="text-slate-700"><?= htmlspecialchars($staff['staff_position']) ?></p>
    <p class="text-slate-700"><?= htmlspecialchars($staff['shift']) ?></p>
  <?php endforeach; ?>
</div>

<!-- Inpatients -->
<div class="hidden md:flex flex-row justify-between my-2 items-end">
  <h1 class="text-xl text-slate-700 font-[700]">Inpatients on Ward <?php echo $ward_details['ward_number']; ?></h1>
</div>
<div class="hidden md:grid grid-cols-7 bg-slate-200 p-4 rounded-lg">
  <?php
  $patients = $connection->query(
    "SELECT patient.patient_number, 
            patient.firstname || ' ' || patient.lastname AS patient_name, 
            inpatient.waiting_list_date, 
            inpatient.expected_stay, 
            inpatient.date_placed, 
            inpatient.date_expected_to_leave, 
            inpatient.date_actual_left
     FROM inpatient
     JOIN allocation ON inpatient.allocation_id = allocation.allocation_id
     JOIN appointment ON inpatient.appointment_number = appointment.appointment_number
     JOIN patients.patient ON appointment.patient_number = patients.patient.patient_number
     WHERE ward_number = " . $ward_details['ward_number']
  )->fetchAll(PDO::FETCH_ASSOC);
  ?>

  <?php if (count($patients) == 0) : ?>
    <h1 class="font-[400] text-slate-600 text-xl col-span-7">
      No inpatients on ward <?= htmlspecialchars($ward_details['ward_number']) ?>.
    </h1>
  <?php else : ?>
    <h1 class="font-[700] text-slate-600">Patient Number</h1>
    <h1 class="font-[700] text-slate-600">Patient Name</h1>
    <h1 class="font-[700] text-slate-600">On Waiting List</h1>
    <h1 class="font-[700] text-slate-600">Expected Stay (Days)</h1>
    <h1 class="font-[700] text-slate-600">Date Placed</h1>
    <h1 class="font-[700] text-slate-600">Date Expected to Leave</h1>
    <h1 class="font-[700] text-slate-600">Date Actual Leave</h1>
    <?php foreach ($patients as $patient) : ?>
      <p class="text-slate-700"><?= htmlspecialchars($patient['patient_number']) ?></p>
      <p class="text-slate-700"><?= htmlspecialchars($patient['patient_name']) ?></p>
      <p class="text-slate-700"><?= htmlspecialchars($patient['waiting_list_date']) ?></p>
      <p class="text-slate-700"><?= htmlspecialchars($patient['expected_stay']) ?></p>
      <p class="text-slate-700"><?= htmlspecialchars($patient['date_placed']) ?></p>
      <p class="text-slate-700"><?= htmlspecialchars($patient['date_expected_to_leave']) ?></p>
      <p class="text-slate-700"><?= htmlspecialchars($patient['date_actual_left']) ?></p>
    <?php endforeach; ?>
  <?php endif; ?>
</div>

<!-- Outpatients -->
<div class="hidden md:flex flex-row justify-between my-2 items-end">
  <h1 class="text-xl text-slate-700 font-[700]">Outpatients</h1>
</div>
<div class="hidden md:grid grid-cols-4 bg-slate-200 p-4 rounded-lg">
  <?php
  $outpatients = $connection->query(
    "SELECT appointment.appointment_number, 
            patient.firstname || ' ' || patient.lastname AS patient_name, 
            staff.firstname || ' ' || staff.lastname AS staff_name, 
            appointment.room 
     FROM outpatient
     JOIN appointment ON outpatient.appointment_number = appointment.appointment_number
     JOIN staffs.staff ON appointment.staff_number = staff.staff_number
     JOIN patients.patient ON appointment.patient_number = patient.patient_number"
  )->fetchAll(PDO::FETCH_ASSOC);
  ?>

  <?php if (count($outpatients) == 0) : ?>
    <h1 class="font-[400] text-slate-600 text-xl col-span-4">No outpatients.</h1>
  <?php else : ?>
    <h1 class="font-[700] text-slate-600">Appointment Number</h1>
    <h1 class="font-[700] text-slate-600">Patient Name</h1>
    <h1 class="font-[700] text-slate-600">Staff In Charge</h1>
    <h1 class="font-[700] text-slate-600">Room</h1>
    <?php foreach ($outpatients as $patient) : ?>
      <p class="text-slate-700"><?= htmlspecialchars($patient['appointment_number']) ?></p>
      <p class="text-slate-700"><?= htmlspecialchars($patient['patient_name']) ?></p>
      <p class="text-slate-700"><?= htmlspecialchars($patient['staff_name']) ?></p>
      <p class="text-slate-700"><?= htmlspecialchars($patient['room']) ?></p>
    <?php endforeach; ?>
  <?php endif; ?>
</div>