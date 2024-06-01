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
  $staffs = $connection->query("SELECT DISTINCT staff.staff_number, staff.firstname || ' ' || staff.lastname AS staff_name, staff.staff_position, allocation.shift FROM allocation
        JOIN staffs.staff ON allocation.staff_number = staffs.staff.staff_number
     WHERE ward_number = " . $ward_details['ward_number'])->fetchAll(PDO::FETCH_ASSOC);
  foreach ($staffs as $staff) {
    echo "
          <p class='text-slate-700'>" . $staff['staff_number'] . "</p>
          <p class='text-slate-700'>" . $staff['staff_name'] . "</p>
          <p class='text-slate-700'>" . $staff['staff_position'] . "</p>
          <p class='text-slate-700'>" . $staff['shift'] . "</p>
        ";
  }
  ?>
</div>

<!-- Inpatients -->
<div class="hidden md:flex flex-row justify-between my-2 items-end">
  <h1 class="text-xl text-slate-700 font-[700]">Inpatients on Ward <?php echo $ward_details['ward_number']; ?></h1>
</div>
<div class="hidden md:grid grid-cols-7 bg-slate-200 p-4 rounded-lg">

  <?php
  $patients = $connection->query("SELECT patient.patient_number, patient.firstname || ' ' || patient.lastname AS patient_name, 
        inpatient.waiting_list_date, inpatient.expected_stay, inpatient.date_placed, inpatient.date_expected_to_leave,
        inpatient.date_actual_left
        FROM inpatient
        JOIN allocation ON inpatient.allocation_id = allocation.allocation_id
        JOIN appointment ON inpatient.appointment_number = appointment.appointment_number
        JOIN patients.patient ON appointment.patient_number = patients.patient.patient_number
        WHERE ward_number = " . $ward_details['ward_number'])->fetchAll(PDO::FETCH_ASSOC);

  if (count($patients) == 0) {
    echo "<h1 class='font-[400] text-slate-600 text-xl col-span-7'>No inpatients on ward " . $ward_details['ward_number'] . ".</h1>";
  } else {
    echo " <h1 class='font-[700] text-slate-600'>Patient Number</h1>
    <h1 class='font-[700] text-slate-600'>Patient Name</h1>
    <h1 class='font-[700] text-slate-600'>On Waiting List</h1>
    <h1 class='font-[700] text-slate-600'>Expected Stay (Days)</h1>
    <h1 class='font-[700] text-slate-600'>Date Placed</h1>
    <h1 class='font-[700] text-slate-600'>Date Expected to Leave</h1>
    <h1 class='font-[700] text-slate-600'>Date Actual Leave</h1>";
    foreach ($patients as $patient) {
      echo "
      
            <p class='text-slate-700'>" . $patient['patient_number'] . "</p>
            <p class='text-slate-700'>" . $patient['patient_name'] . "</p>
            <p class='text-slate-700'>" . $patient['waiting_list_date'] . "</p>
            <p class='text-slate-700'>" . $patient['expected_stay'] . "</p>
            <p class='text-slate-700'>" . $patient['date_placed'] . "</p>
            <p class='text-slate-700'>" . ($patient['date_expected_to_leave']) . "</p>
            <p class='text-slate-700'>" . ($patient['date_actual_left']) . "</p>
          ";
    }
  }
  ?>
</div>

<!-- Outpatients -->
<div class="hidden md:flex flex-row justify-between my-2 items-end">
  <h1 class="text-xl text-slate-700 font-[700]">Outpatients</h1>
</div>
<div class="hidden md:grid grid-cols-4 bg-slate-200 p-4 rounded-lg">
  <?php
  $outpatients = $connection->query("SELECT appointment.appointment_number, patient.firstname || ' ' || patient.lastname AS patient_name, 
  staff.firstname || ' ' || staff.lastname AS staff_name, appointment.room FROM outpatient
  JOIN appointment ON outpatient.appointment_number = appointment.appointment_number
  JOIN staffs.staff ON appointment.staff_number = staff.staff_number
  JOIN patients.patient ON appointment.patient_number = patient.patient_number")->fetchAll(PDO::FETCH_ASSOC);

  if (count($outpatients) == 0) {
    echo "<h1 class='font-[400] text-slate-600 text-xl col-span-4'>No outpatients.</h1>";
  } else {
    echo "<h1 class='font-[700] text-slate-600'>Appointment Number</h1>
    <h1 class='font-[700] text-slate-600'>Patient Name</h1>
    <h1 class='font-[700] text-slate-600'>Staff In Charge</h1>
    <h1 class='font-[700] text-slate-600'>Room</h1>";
    foreach ($outpatients as $patient) {
      echo "
            <p class='text-slate-700'>" . $patient['appointment_number'] . "</p>
            <p class='text-slate-700'>" . $patient['patient_name'] . "</p>
            <p class='text-slate-700'>" . $patient['staff_name'] . "</p>
            <p class='text-slate-700'>" . $patient['room'] . "</p>
          ";
    }
  }
  ?>
</div>

<!-- Items/Supplies -->
<div class="hidden md:flex flex-row justify-between my-2 items-end">
  <h1 class="text-xl text-slate-700 font-[700]">Items/Supplies used on Ward <?php echo $ward_details['ward_number']; ?>
  </h1>
</div>
<div class="hidden md:grid grid-cols-3 bg-slate-200 p-4 rounded-lg">
  <?php
  $supplies = $connection->query("SELECT ward_number, supplies.item_name, supplies.description, supplies.reorder_level FROM allocation
        JOIN wards.supplies ON allocation.supply_id = supplies.supply_id
        WHERE ward_number = " . $ward_details['ward_number'])->fetchAll(PDO::FETCH_ASSOC);

  if (count($supplies) == 0) {
    echo "<h1 class='font-[400] text-slate-600 text-xl col-span-3'>No items/supplies on ward " . $ward_details['ward_number'] . ".</h1>";
  } else {
    echo "            <h1 class='font-[700] text-slate-600'>Item Name</h1>
    <h1 class='font-[700] text-slate-600'>Item Description</h1>
    <h1 class='font-[700] text-slate-600'>Item Reorder Level</h1>";
    foreach ($supplies as $item) {
      echo "
            <p class='text-slate-700'>" . $item['item_name'] . "</p>
            <p class='text-slate-700'>" . $item['description'] . "</p>
            <p class='text-slate-700'>" . $item['reorder_level'] . "</p>
          ";
    }
  }
  ?>
</div>

<!-- Patient Medication Details -->
<div class="hidden md:flex flex-row justify-between my-2 items-end">
  <h1 class="text-xl text-slate-700 font-[700]">Patient Medication Details</h1>
  <form action="<?php echo htmlspecialchars($_SERVER["PHP_SELF"]); ?>" method="GET" name="inpatient_form">
    <select name="inpatient_form[inpatient_number]" class="p-2 rounded-md shadow-sm focus:outline-none focus:border-slate-500 focus:ring-slate-500 focus:ring-2 text-slate-700">
      <?php
      foreach ($patients_medications as $patient) {
        echo "<option value='" . $patient['bed_number'] . "'>" . $patient['bed_number'] . " - " . $patient['patient_name'] . "</option>";
      }
      ?>
    </select>
    <input type="submit" value="View patient" class="cursor-pointer bg-slate-300 rounded-lg p-2 text-slate-600 text-center transition-all duration-250 delay-0 ease-in-out hover:bg-slate-400 hover:text-slate-100 hover:shadow-lg" />
  </form>
</div>
<div class="hidden md:flex flex-col text-slate-600">
  <h1>Patient Number: <b>P<?php echo $patient_medication_details[0]['patient_number']; ?></b></h1>
  <div class="grid grid-cols-2 grid-rows-2 bg-slate-200 p-4 rounded-lg">
    <h1>Full Name: <b><?php echo $patient_medication_details[0]['patient_name']; ?></b></h1>
    <h1>Ward Number: <b><?php echo $patient_medication_details[0]['ward_number']; ?></b></h1>
    <h1>Bed Number: <b><?php echo $patient_medication_details[0]['bed_number']; ?></b></h1>
    <h1>Ward Name: <b><?php echo $patient_medication_details[0]['ward_name']; ?></b></h1>
  </div>
  <div class="grid grid-cols-7 bg-slate-200 p-4 rounded-lg mt-2 gap-4 mb-4">
    <h1 class='font-[700] text-slate-600'>Drug Number</h1>
    <h1 class='font-[700] text-slate-600'>Drug Name</h1>
    <h1 class='font-[700] text-slate-600'>Drug Description</h1>
    <h1 class='font-[700] text-slate-600'>Dosage</h1>
    <h1 class='font-[700] text-slate-600'>Method Of Admin</h1>
    <h1 class='font-[700] text-slate-600'>Start Date</h1>
    <h1 class='font-[700] text-slate-600'>Finish Date</h1>
    <?php
    foreach ($patient_medication_details as $medication) {
      echo "
              <p class='text-slate-700'>" . $medication['drug_number'] . "</p>
              <p class='text-slate-700'>" . $medication['drug_name'] . "</p>
              <p class='text-slate-700'>" . $medication['description'] . "</p>
              <p class='text-slate-700'>" . $medication['dosage'] . "</p>
              <p class='text-slate-700'>" . $medication['method_of_admin'] . "</p>
              <p class='text-slate-700'>" . $medication['starting_date'] . "</p>
              <p class='text-slate-700'>" . $medication['finished_date'] . "</p>
            ";
    }

    ?>
  </div>
</div>