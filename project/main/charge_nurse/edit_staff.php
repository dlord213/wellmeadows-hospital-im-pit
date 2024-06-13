<?php
session_start();
require '../libraries/connect_to_database.php';
require './libraries/get_ward_details.php';

$staff_number = $_SESSION['staff_number'];
$staff_name = $_SESSION['staff_name'];
$staff_position = $_SESSION['staff_position'];

$connection = connectToDatabase($staff_position);

if ($connection) {
  $ward_details = getWardDetails($connection, $staff_number);

  $staffs = $connection->query("SELECT DISTINCT staff.staff_number, staff.firstname || ' ' || staff.lastname AS staff_name, staff.staff_position, allocation.shift FROM allocation
  JOIN staffs.staff ON allocation.staff_number = staffs.staff.staff_number
  WHERE ward_number = " . $ward_details['ward_number'])->fetchAll(PDO::FETCH_ASSOC);

  $positions = array("Nurse", "Consultant", "Staff Nurse");
  $shifts = array("Early", "Late", "Night");
}

if ($_SERVER['REQUEST_METHOD'] == "POST") {
  try {
    $connection->beginTransaction();

    $preparedStatementOne = $connection->prepare("UPDATE allocation SET shift = ? WHERE staff_number = ? AND ward_number = ?");
    $preparedStatementOne->execute([
      $_POST['selected_shift'],
      $_POST['selected_staff_number'],
      $ward_details['ward_number']
    ]);

    $preparedStatementTwo = $connection->prepare("UPDATE staffs.staff SET staff_position = ? WHERE staff_number = ?;");
    $preparedStatementTwo->execute([
      $_POST['selected_position'],
      $_POST['selected_staff_number']
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
  <title>Hospital | Edit Staff</title>
  <?php include '../../libraries/header_scripts.php' ?>
</head>

<body class="bg-slate-100">
  <main class="h-[100vh] max-w-xl w-full mx-auto flex flex-col justify-center">
    <h1 class="text-3xl font-[900] text-slate-800">Edit Staff</h1>
    <div class="bg-slate-200 p-4 rounded-lg mt-4 flex flex-col gap-4">
      <h1 class="text-slate-700 text-xl font-bold">Staff details</h1>
      <div class="w-full h-[2px] bg-slate-400"></div>
      <form method="POST" action="<?php echo htmlspecialchars($_SERVER["PHP_SELF"]); ?>" class="flex flex-col gap-2">
        <div class="flex flex-col gap-2">
          <h1 class="text-slate-800">Staff Number</h1>
          <select name="selected_staff_number" class="p-2 rounded-md shadow-sm focus:outline-none focus:border-slate-500 focus:ring-slate-500 focus:ring-2 text-slate-700">
            <?php foreach ($staffs as $staff) : ?>
              <option value="<?= htmlspecialchars($staff['staff_number']) ?>">
                <?= htmlspecialchars($staff['staff_number']) ?> - <?= htmlspecialchars($staff['staff_name']) ?>
              </option>
            <?php endforeach; ?>

          </select>
        </div>
        <div class="flex flex-col gap-2">
          <h1 class="text-slate-800">Shift</h1>
          <select name="selected_shift" class="p-2 rounded-md shadow-sm focus:outline-none focus:border-slate-500 focus:ring-slate-500 focus:ring-2 text-slate-700">
            <?php foreach ($shifts as $shift) : ?>
              <option value="<?= htmlspecialchars($shift) ?>"><?= htmlspecialchars($shift) ?></option>
            <?php endforeach; ?>
          </select>
        </div>
        <div class="flex flex-col gap-2">
          <h1 class="text-slate-800">Position</h1>
          <select name="selected_position" class="p-2 rounded-md shadow-sm focus:outline-none focus:border-slate-500 focus:ring-slate-500 focus:ring-2 text-slate-700">
            <?php foreach ($positions as $position) : ?>
              <option value="<?= htmlspecialchars($position) ?>"><?= htmlspecialchars($position) ?></option>
            <?php endforeach; ?>
          </select>
        </div>
        <input type="submit" class="bg-slate-300 cursor-pointer rounded-lg p-2 text-slate-600 text-center transition-all duration-250 delay-0 ease-in-out hover:bg-slate-400 hover:text-slate-100 hover:shadow-lg" value="Update" />
      </form>
    </div>
  </main>
</body>

</html>