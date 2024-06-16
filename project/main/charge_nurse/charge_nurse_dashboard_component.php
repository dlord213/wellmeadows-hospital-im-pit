<?php
$staffs = $connection->query("SELECT DISTINCT staff.staff_number, staff.firstname || ' ' || staff.lastname AS staff_name, staff.staff_position, allocation.shift FROM allocation
        JOIN staffs.staff ON allocation.staff_number = staffs.staff.staff_number
        WHERE ward_number = " . $ward_details['ward_number'])->fetchAll(PDO::FETCH_ASSOC);
$patients = $connection->query("SELECT patient.patient_number, patient.firstname || ' ' || patient.lastname AS patient_name, 
        inpatient.waiting_list_date, inpatient.expected_stay, inpatient.date_placed, inpatient.date_expected_to_leave,
        inpatient.date_actual_left
        FROM inpatient
        JOIN allocation ON inpatient.allocation_id = allocation.allocation_id
        JOIN appointment ON inpatient.appointment_number = appointment.appointment_number
        JOIN patients.patient ON appointment.patient_number = patients.patient.patient_number
        WHERE ward_number = " . $ward_details['ward_number'])->fetchAll(PDO::FETCH_ASSOC);
$history = $connection->query("SELECT staff.staff_number, staff.firstname || ' ' || staff.lastname AS staff_name, staff.staff_position, allocation_history.shift 
                              FROM allocation_history 
                              JOIN staffs.staff ON allocation_history.staff_number = staffs.staff.staff_number ");


?>

<!-- Ward -->
<div class="flex flex-row justify-between my-2 items-end">
  <h1 class="text-xl text-slate-700 font-[700]">Ward <?php echo $ward_details['ward_number']; ?></h1>
  <div class="flex flex-row gap-2">
    <a href="./charge_nurse/add_staff.php" class="hidden bg-slate-300 rounded-lg p-2 text-slate-600 text-center transition-all duration-250 delay-0 ease-in-out hover:bg-slate-400 hover:text-slate-100 hover:shadow-lg">Add
      staff</a>
    <a href="./charge_nurse/edit_staff.php" class="bg-slate-300 rounded-lg p-2 text-slate-600 text-center transition-all duration-250 delay-0 ease-in-out hover:bg-slate-400 hover:text-slate-100 hover:shadow-lg">Edit
      staff</a>
    <button class="bg-slate-300 rounded-lg p-2 text-slate-600 text-center transition-all duration-250 delay-0 ease-in-out hover:bg-slate-400 hover:text-slate-100 hover:shadow-lg" onclick="handleHistoryContainer()">History</button>
  </div>
</div>
<div class="grid grid-cols-4 bg-slate-200 p-4 rounded-lg">
  <h1 class='font-[700] text-slate-600'>Staff Number</h1>
  <h1 class='font-[700] text-slate-600'>Staff Name</h1>
  <h1 class='font-[700] text-slate-600'>Staff Position</h1>
  <h1 class='font-[700] text-slate-600'>Shift</h1>
  <?php foreach ($staffs as $staff) : ?>
    <p class='text-slate-700'><?= htmlspecialchars($staff['staff_number']) ?></p>
    <p class='text-slate-700'><?= htmlspecialchars($staff['staff_name']) ?></p>
    <p class='text-slate-700'><?= htmlspecialchars($staff['staff_position']) ?></p>
    <p class='text-slate-700'><?= htmlspecialchars($staff['shift']) ?></p>
  <?php endforeach; ?>
</div>


<!-- Inpatients -->
<div class="flex flex-row justify-between my-2 items-end">
  <h1 class="text-xl text-slate-700 font-[700]">Inpatients on Ward <?php echo $ward_details['ward_number']; ?></h1>
  <div class="flex flex-row gap-2">
    <a href="./charge_nurse/transfer_patient.php" class="bg-slate-300 rounded-lg p-2 text-slate-600 text-center transition-all duration-250 delay-0 ease-in-out hover:bg-slate-400 hover:text-slate-100 hover:shadow-lg">Transfer
      patient</a>
  </div>
</div>
<div class="grid grid-cols-5 bg-slate-200 p-4 rounded-lg">
  <h1 class='font-[700] text-slate-600'>Patient Number</h1>
  <h1 class='font-[700] text-slate-600'>Patient Name</h1>
  <h1 class='font-[700] text-slate-600'>On Waiting List</h1>
  <h1 class='font-[700] text-slate-600'>Expected Stay (Days)</h1>
  <h1 class='font-[700] text-slate-600'>Date Placed</h1>
  <?php if (count($patients) == 0) : ?>
    <h1 class='font-[400] text-slate-600 text-xl col-span-7'>No inpatients on ward <?= htmlspecialchars($ward_details['ward_number']) ?>.</h1>
  <?php else : ?>
    <?php foreach ($patients as $patient) : ?>
      <p class='text-slate-700'><?= htmlspecialchars($patient['patient_number']) ?></p>
      <p class='text-slate-700'><?= htmlspecialchars($patient['patient_name']) ?></p>
      <p class='text-slate-700'><?= htmlspecialchars($patient['waiting_list_date']) ?></p>
      <p class='text-slate-700'><?= htmlspecialchars($patient['expected_stay']) ?></p>
      <p class='text-slate-700'><?= htmlspecialchars($patient['date_placed']) ?></p>
    <?php endforeach; ?>
  <?php endif; ?>
</div>

<!-- History -->
<div class="hidden" id="history-container">
  <div class="flex flex-row justify-between my-2 items-end">
    <h1 class="text-xl text-slate-700 font-[700]">Previous shifts in Ward <?php echo $ward_details['ward_number']; ?></h1>
  </div>
  <div class="grid grid-cols-4 bg-slate-200 p-4 rounded-lg">
    <h1 class='font-[700] text-slate-600'>Staff Number</h1>
    <h1 class='font-[700] text-slate-600'>Staff Name</h1>
    <h1 class='font-[700] text-slate-600'>Staff Position</h1>
    <h1 class='font-[700] text-slate-600'>Shift</h1>
    <?php foreach ($history as $staff) : ?>
      <p class='text-slate-700'><?= htmlspecialchars($staff['staff_number']) ?></p>
      <p class='text-slate-700'><?= htmlspecialchars($staff['staff_name']) ?></p>
      <p class='text-slate-700'><?= htmlspecialchars($staff['staff_position']) ?></p>
      <p class='text-slate-700'><?= htmlspecialchars($staff['shift']) ?></p>
    <?php endforeach; ?>
  </div>
</div>

<script>
  let historyContainer = document.getElementById("history-container");

  function handleHistoryContainer() {
    historyContainer.classList.toggle("hidden");
  }
</script>