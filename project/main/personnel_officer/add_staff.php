<?php
session_start();
require '../libraries/connect_to_database.php';
require './libraries/get_ward_details.php';

$staff_position = $_SESSION['staff_position'];

$connection = connectToDatabase($staff_position);

if ($connection) {
  $wards = $connection->query("SELECT * FROM wards.ward")->fetchAll();
  $staffs = $connection->query("SELECT staff_number, firstname || ' ' || lastname AS staff_name FROM staffs.staff
                                WHERE staff_position != 'Medical Director' AND staff_position != 'Charge Nurse' AND staff_position != 'Personnel Officer'
                                ORDER BY staff_number ASC")->fetchAll();
  $shifts = array("Early", "Late", "Night");
}

if ($_SERVER['REQUEST_METHOD'] == "POST") {
  try {
    $connection->beginTransaction();

    $preparedStatement = $connection->prepare("
      INSERT INTO allocation (ward_number, staff_number, shift)
      SELECT ?, ?, ?
      WHERE NOT EXISTS (
        SELECT 1 FROM allocation
        WHERE ward_number = ?
        AND staff_number = ?
        AND shift = ?
      )
    ");

    $wardNumber = $_POST['selected_ward_number'];
    $staffNumber = $_POST['selected_staff_number'];
    $shift = $_POST['selected_shift'];

    $preparedStatement->execute([
      $wardNumber,
      $staffNumber,
      $shift,
      $wardNumber,
      $staffNumber,
      $shift
    ]);

    $connection->commit();

    header("Location: ../index.php");
    exit();
  } catch (Exception $e) {
    $connection->rollBack();
    echo "Error: " . $e->getMessage();
  }
}
?>

<!DOCTYPE html>
<html lang="en">

<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Hospital | Add Staff</title>
  <?php include '../../libraries/header_scripts.php' ?>
</head>

<body class="bg-slate-100">
  <main class="h-[100vh] max-w-xl w-full mx-auto flex flex-col justify-center">
    <h1 class="text-3xl font-[900] text-slate-800">Add Staff</h1>
    <div class="bg-slate-200 p-4 rounded-lg mt-4 flex flex-col gap-4">
      <h1 class="text-slate-700 text-xl font-bold">Staff details</h1>
      <div class="w-full h-[2px] bg-slate-400"></div>
      <form method="POST" action="<?php echo htmlspecialchars($_SERVER["PHP_SELF"]); ?>" class="flex flex-col gap-2">
        <!-- Staff Number Selection -->
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

        <!-- Ward Number Selection -->
        <div class="flex flex-col gap-2">
          <h1 class="text-slate-800">Ward Number</h1>
          <select name="selected_ward_number" class="p-2 rounded-md shadow-sm focus:outline-none focus:border-slate-500 focus:ring-slate-500 focus:ring-2 text-slate-700">
            <?php foreach ($wards as $ward) : ?>
              <option value="<?= htmlspecialchars($ward['ward_number']) ?>">
                <?= htmlspecialchars($ward['ward_number']) ?> - <?= htmlspecialchars($ward['ward_name']) ?>
              </option>
            <?php endforeach; ?>
          </select>
        </div>

        <!-- Shift Selection -->
        <div class="flex flex-col gap-2">
          <h1 class="text-slate-800">Shift</h1>
          <select name="selected_shift" class="p-2 rounded-md shadow-sm focus:outline-none focus:border-slate-500 focus:ring-slate-500 focus:ring-2 text-slate-700">
            <?php foreach ($shifts as $shift) : ?>
              <option value="<?= htmlspecialchars($shift) ?>"><?= htmlspecialchars($shift) ?></option>
            <?php endforeach; ?>
          </select>
        </div>

        <!-- Submit Button -->
        <input type="submit" class="bg-slate-300 cursor-pointer rounded-lg p-2 text-slate-600 text-center transition-all duration-250 delay-0 ease-in-out hover:bg-slate-400 hover:text-slate-100 hover:shadow-lg" value="Add" />
      </form>

    </div>
  </main>
</body>

</html>