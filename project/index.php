<?php

session_start();
require './libraries/functions.php';
require './libraries/index_checker.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
  $username = $_POST['username'];
  $password = $_POST['password'];

  try {
    $connection = new PDO("pgsql:host=localhost;dbname=wellmeadows_hospital_pit", "postgres", "dlord213");
    $connection->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
  } catch (PDOException $e) {
    die("Database connection failed: " . $e->getMessage());
  }

  if ($connection) {
    $staffDetails = getStaffDetails($connection, $username, $password);

    if ($staffDetails) {
      setSession($staffDetails);
      header("Location: ./main/index.php");
      exit();
    } else {
      $doctorDetails = getDoctorDetails($connection, $username, $password);

      if ($doctorDetails) {
        setSession($doctorDetails, 'Doctor');
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
    <form method="POST" action="<?php echo htmlspecialchars($_SERVER["PHP_SELF"]); ?>" class="bg-slate-200 p-4 rounded-lg mt-2 flex flex-col gap-2">
      <input type="text" name="username" placeholder="Username" class="p-4 rounded-md shadow-md focus:outline-none focus:border-slate-500 focus:ring-slate-500 focus:ring-2 text-slate-700" required />
      <input type="password" name="password" placeholder="********" class="p-4 rounded-md shadow-md focus:outline-none focus:border-slate-500 focus:ring-slate-500 focus:ring-2 text-slate-700" required />
      <input type="submit" value="Login" class="cursor:pointer bg-slate-300 w-full rounded-lg p-2 text-slate-700 text-center transition-all duration-250 delay-0 ease-in-out hover:bg-slate-400 hover:text-slate-100 hover:shadow-lg" />
    </form>
  </div>
</body>

</html>