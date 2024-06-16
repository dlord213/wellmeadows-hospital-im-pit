<?php
$ward_number = intval($ward_details['ward_number']);

if ($connection) {

  $staffs = $connection->query("SELECT DISTINCT staff.staff_number, staff.firstname || ' ' || staff.lastname AS staff_name, staff.staff_position, allocation.shift FROM allocation
  JOIN staffs.staff ON allocation.staff_number = staffs.staff.staff_number
  WHERE ward_number = " . $ward_details['ward_number'])->fetchAll(PDO::FETCH_ASSOC);

  $history = $connection->query("SELECT staff.staff_number, staff.firstname || ' ' || staff.lastname AS staff_name, staff.staff_position, allocation_history.shift 
                        FROM allocation_history 
                        JOIN staffs.staff ON allocation_history.staff_number = staffs.staff.staff_number ");
}
?>

<!-- Ward -->
<div class="hidden md:flex flex-row justify-between my-2 items-end">
  <h1 class="text-xl text-slate-700 font-[700]">Staffs on Ward <?php echo $ward_details['ward_number']; ?></h1>
  <div class="flex flex-row gap-2">
    <a href="./personnel_officer/add_staff.php?ward_number=<?php echo $ward_number ?>" class="bg-slate-300 rounded-lg p-2 text-slate-600 text-center transition-all duration-250 delay-0 ease-in-out hover:bg-slate-400 hover:text-slate-100 hover:shadow-lg">Add
      staff</a>
    <button class="bg-slate-300 rounded-lg p-2 text-slate-600 text-center transition-all duration-250 delay-0 ease-in-out hover:bg-slate-400 hover:text-slate-100 hover:shadow-lg" onclick="handleHistoryContainer()">History</button>
  </div>
</div>
<div class="hidden md:grid grid-cols-4 bg-slate-200 p-4 rounded-lg">
  <h1 class='font-[700] text-slate-600'>Staff Number</h1>
  <h1 class='font-[700] text-slate-600'>Staff Name</h1>
  <h1 class='font-[700] text-slate-600'>Staff Position</h1>
  <h1 class='font-[700] text-slate-600'>Shift</h1>
  <?php

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