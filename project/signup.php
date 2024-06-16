<?php

session_start();
require './libraries/functions.php';
require './libraries/index_checker.php';

$error_message = '';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
  $username = $_POST['username'];
  $password = $_POST['password'];
  $staff_number =  $_POST['staff_number'];

  try {
    $connection = new PDO("pgsql:host=localhost;dbname=wellmeadows_hospital_pit", "postgres", "dlord213");
    $connection->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
  } catch (PDOException $e) {
    die("Database connection failed: " . $e->getMessage());
  }

  if ($connection) {
    $accountExists = $connection->query("SELECT staff_number FROM users.staff_user WHERE staff_number = " . $staff_number)->fetch(PDO::FETCH_ASSOC);

    if ($accountExists) {
      $error_message = "An account with this staff number already exists.";
    } else {

      try {
        $connection->beginTransaction();

        $stmt = $connection->prepare("INSERT INTO users.staff_user(username, _password, staff_number) VALUES (?, ?, ?)");
        $stmt->execute([$username, $password, $staff_number]);

        $connection->commit();
        header('Location: ./index.php');
        exit();
      } catch (PDOException $e) {
        $connection->rollBack();
        $error_message = $e->getMessage();
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
  <title>Hospital | Signup</title>
  <?php include './libraries/header_scripts.php' ?>
</head>


<body class="bg-slate-100">
  <div class="max-w-xl w-full mx-auto flex flex-col justify-center h-[100vh]">
    <h1 class="font-[900] text-slate-800 text-4xl">Wellmeadows Hospital</h1>
    <form method="POST" action="<?php echo htmlspecialchars($_SERVER["PHP_SELF"]); ?>" class="bg-slate-200 p-4 rounded-lg mt-2 flex flex-col gap-2">
      <input type="text" name="username" placeholder="Username" class="p-4 rounded-md shadow-md focus:outline-none focus:border-slate-500 focus:ring-slate-500 focus:ring-2 text-slate-700" required />
      <input type="password" name="password" placeholder="********" class="p-4 rounded-md shadow-md focus:outline-none focus:border-slate-500 focus:ring-slate-500 focus:ring-2 text-slate-700" required />
      <input type="number" name="staff_number" placeholder="Staff Number" min="1" class="p-4 rounded-md shadow-md focus:outline-none focus:border-slate-500 focus:ring-slate-500 focus:ring-2 text-slate-700" required />
      <input type="submit" value="Signup" class="cursor-pointer bg-slate-300 w-full rounded-lg p-2 text-slate-700 text-center transition-all duration-250 delay-0 ease-in-out hover:bg-slate-400 hover:text-slate-100 hover:shadow-lg" />
    </form>
    <?php if (!empty($error_message)) : ?>
      <p class="font-[500] text-red-600 my-2 p-4 bg-red-200 rounded-lg"><?= htmlspecialchars($error_message) ?></p>
    <?php else : ?>
      <p class="font-[500] text-slate-600 my-2 p-4 bg-slate-200 rounded-lg">To sign-up, you must know your staff ID. If you don't have one, contact your system administrator.</p>
    <?php endif; ?>
    <a href="./index.php" class="font-[500] text-slate-400 my-1 hover:text-slate-500">Already have an account?</a>
  </div>
</body>

</html>