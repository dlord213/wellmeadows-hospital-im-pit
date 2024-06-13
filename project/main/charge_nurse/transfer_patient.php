<?php
session_start();
require '../libraries/connect_to_database.php';
require './libraries/get_ward_details.php';
require './libraries/get_allocation_id.php';

$staff_number = $_SESSION['staff_number'];
$staff_name = $_SESSION['staff_name'];
$staff_position = $_SESSION['staff_position'];

$connection = connectToDatabase($staff_position);

if ($connection) {
  $ward_details = getWardDetails($connection, $staff_number);
  $allocation_details = getAllocationID($connection, $ward_details['ward_number'], $staff_number);

  $patients = $connection->query("SELECT appointment.appointment_number, patient.patient_number, firstname || ' ' || lastname AS patient_name FROM appointment
  JOIN patients.patient ON appointment.patient_number = patient.patient_number")->fetchAll(PDO::FETCH_ASSOC);
}

if ($_SERVER['REQUEST_METHOD'] == "POST") {
  try {
    $connection->beginTransaction();

    $preparedStatement = $connection->prepare("INSERT INTO inpatient(allocation_id, appointment_number, waiting_list_date, expected_stay, date_placed)
    VALUES (?, ?, ?, ?, ?)");

    $preparedStatement->execute([
      $allocation_details['allocation_id'],
      $_POST['selected_appointment_number'],
      date('Y-m-d', strtotime($_POST["on_waiting_list_date"])),
      (int) $_POST['expected_stay_input'],
      date('Y-m-d', strtotime($_POST["date_placed_input"]))
    ]);

    $connection->commit();

    header("Location: ../index.php");
    exit();
  } catch (Exception $e) {
    $connection->rollBack();
    echo $e->getMessage();
  }
}
?>

<!DOCTYPE html>
<html lang="en">

<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Hospital | Transfer to inpatient clinic</title>
  <?php include '../../libraries/header_scripts.php' ?>
</head>


<body class="bg-slate-100">
  <main class="h-[100vh] max-w-xl w-full mx-auto flex flex-col justify-center">
    <h1 class="text-3xl font-[900] text-slate-800">Transfer to inpatient</h1>
    <div class="bg-slate-200 p-4 rounded-lg mt-4 flex flex-col gap-4">
      <div class="gap-2 flex flex-col">
        <h1 class="text-slate-700 text-xl font-bold">Appointment details</h1>
        <p class="text-slate-500 font-[500]">You need an appointment before you can transfer the patient to the
          inpatient clinic.</p>
      </div>
      <div class="w-full h-[2px] bg-slate-400"></div>
      <form method="POST" action="<?php echo htmlspecialchars($_SERVER["PHP_SELF"]); ?>" class="flex flex-col gap-2">
        <div class="flex flex-col gap-2">
          <h1 class="text-slate-800">Patient Number</h1>
          <select name="selected_appointment_number" class="p-2 rounded-md shadow-sm focus:outline-none focus:border-slate-500 focus:ring-slate-500 focus:ring-2 text-slate-700">
            <?php foreach ($patients as $patient) : ?>
              <option value="<?= htmlspecialchars($patient['appointment_number']) ?>">
                <?= htmlspecialchars($patient['patient_number']) ?> - <?= htmlspecialchars($patient['patient_name']) ?>
              </option>
            <?php endforeach; ?>
          </select>
        </div>
        <div class="flex flex-col gap-2">
          <h1 class="text-slate-800">On Waiting List (Date)</h1>
          <input type="date" name="on_waiting_list_date" class="p-2 rounded-md shadow-sm focus:outline-none focus:border-slate-500 focus:ring-slate-500 focus:ring-2 text-slate-700" />
        </div>
        <div class="flex flex-col gap-2">
          <h1 class="text-slate-800">Date Placed (Or will be placed)</h1>
          <input type="date" name="date_placed_input" class="p-2 rounded-md shadow-sm focus:outline-none focus:border-slate-500 focus:ring-slate-500 focus:ring-2 text-slate-700" />
        </div>
        <div class="flex flex-col gap-2">
          <h1 class="text-slate-800">Expected Stay (Days)</h1>
          <input type="number" name="expected_stay_input" class="p-2 rounded-md shadow-sm focus:outline-none focus:border-slate-500 focus:ring-slate-500 focus:ring-2 text-slate-700" min="1" />
        </div>
        <input type="submit" class="bg-slate-300 cursor-pointer rounded-lg p-2 text-slate-600 text-center transition-all duration-250 delay-0 ease-in-out hover:bg-slate-400 hover:text-slate-100 hover:shadow-lg" value="Update" />
      </form>
    </div>
  </main>
</body>

</html>