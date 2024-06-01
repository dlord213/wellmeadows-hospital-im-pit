<?php

session_start();
require './libraries/index_checker.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
  $username = $_POST['username'];
  $password = $_POST['password'];

  try {
    $connection = new PDO("pgsql:host=localhost;dbname=wellmeadows_hospital_pit", "postgres", "dlord213");
  } catch (PDOException $e) {
    $e->getMessage();
  }

  if ($connection) {
    // Query to get staff details
    $details = $connection->query("SELECT staff.staff_number, staff.firstname || ' ' || staff.lastname AS staff_name, staff.staff_position 
                                   FROM users.staff_user
                                   JOIN staffs.staff ON users.staff_user.staff_number = staffs.staff.staff_number
                                   WHERE username = '$username' AND _password = '$password'")->fetch(PDO::FETCH_ASSOC);

    if ($details !== false && $details['staff_name'] != NULL) {
      $_SESSION['staff_number'] = $details['staff_number'];
      $_SESSION['staff_name'] = $details['staff_name'];
      $_SESSION['staff_position'] = $details['staff_position'];

      header("Location: ./main/index.php");
      exit();
    } else {
      $details = $connection->query("SELECT doctor.doctor_id, doctor.fullname, doctor.address, doctor.telephone_number
                                       FROM users.staff_user
                                       JOIN patients.doctor ON users.staff_user.doctor_id = doctor.doctor_id
                                       WHERE username = '$username' AND _password = '$password'")->fetch(PDO::FETCH_ASSOC);

      if ($details !== false) {
        $_SESSION['staff_position'] = 'Doctor';
        $_SESSION['doctor_id'] = $details['doctor_id'];
        $_SESSION['doctor_fullname'] = $details['fullname'];
        $_SESSION['doctor_address'] = $details['address'];
        $_SESSION['doctor_tel_number'] = $details['telephone_number'];

        header("Location: ./main/index.php");
        exit();
      }
    }
  }
}

?>

<!DOCTYPE html>
<html lang="en">

<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Hospital | Login</title>
  <?php include './libraries/header_scripts.php' ?>
</head>

<body class="bg-slate-100">
  <div class="max-w-xl w-full mx-auto flex flex-col justify-center h-[100vh]">
    <h1 class="font-[900] text-slate-800 text-4xl">Login</h1>
    <form method="POST" action="<?php echo htmlspecialchars($_SERVER["PHP_SELF"]); ?>"
      class="bg-slate-200 p-4 rounded-lg mt-2 flex flex-col gap-2">
      <input type="text" name="username" placeholder="Username"
        class="p-4 rounded-md shadow-md focus:outline-none focus:border-slate-500 focus:ring-slate-500 focus:ring-2 text-slate-700"
        required />
      <input type="password" name="password" placeholder="********"
        class="p-4 rounded-md shadow-md focus:outline-none focus:border-slate-500 focus:ring-slate-500 focus:ring-2 text-slate-700"
        required />
      <input type="submit" value="Login"
        class="cursor:pointer bg-slate-300 w-full rounded-lg p-2 text-slate-700 text-center transition-all duration-250 delay-0 ease-in-out hover:bg-slate-400 hover:text-slate-100 hover:shadow-lg" />
    </form>
  </div>

</body>

</html>