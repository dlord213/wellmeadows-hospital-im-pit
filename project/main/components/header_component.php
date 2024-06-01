<header>
  <div
    class="flex flex-row md:justify-between justify-center md:items-end items-center lg:max-w-7xl md:h-fit h-[100vh] p-4 mx-auto w-full bg-slate-200 rounded-br-lg rounded-bl-lg">
    <div class="flex flex-col">
      <h1 class="font-[900] text-2xl text-slate-800">Wellmeadows Hospital</h1>
      <?php if (in_array($staff_position, array('Nurse', 'Staff', 'Personnel Officer', 'Charge Nurse', 'Medical Director'))): ?>
        <p class="text-slate-600"><b>Staff:</b> <?php echo $staff_name; ?> / <?php echo $staff_position; ?>
        <?php endif; ?>
        <?php if ($staff_position == 'Doctor'): ?>
        <p class="text-slate-600"><b>Doctor:</b> <?php echo $doctor_fullname; ?> (ID: D<?php echo $doctor_id; ?>)
        <p class="text-slate-600"><b>Address:</b> <?php echo $doctor_address; ?>
        <p class="text-slate-600"><b>Telephone Number:</b> <?php echo $doctor_tel_number; ?>
        <?php endif; ?>
        <?php if ($staff_position == "Charge Nurse"): ?>
        <p class="text-slate-600"><b>In charge of ward number:</b> <?php echo $ward_details['ward_number']; ?> /
          <?php echo $ward_details['ward_location']; ?> - <?php echo $ward_details['telephone_ext_number']; ?>
        </p>
      <?php endif; ?>
      <p class="block md:hidden text-slate-600">Please use desktop to access the page.</p>
      <button onclick="window.location.href='./libraries/logout.php';"
        class="md:hidden bg-slate-300 w-full mt-2 rounded-lg p-2 text-slate-600 text-center transition-all duration-250 delay-0 ease-in-out hover:bg-slate-400 hover:text-slate-100 hover:shadow-lg">Logout</button>
    </div>
    <div class="hidden md:flex flex-row items-center gap-4">
      <?php if ($staff_position == "Medical Director"): ?>
        <form action="<?php echo htmlspecialchars($_SERVER["PHP_SELF"]); ?>" method="GET" name="ward_form">
          <select name="ward_form[ward_number]"
            class="p-2 rounded-md shadow-sm focus:outline-none focus:border-slate-500 focus:ring-slate-500 focus:ring-2 text-slate-700">
            <?php
            foreach ($wards as $ward) {
              echo "<option value='" . $ward['ward_number'] . "'>" . $ward['ward_number'] . " - " . $ward['ward_name'] . "</option>";
            }
            ?>
          </select>
          <input type="submit" value="View ward"
            class="cursor-pointer bg-slate-300 rounded-lg p-2 text-slate-600 text-center transition-all duration-250 delay-0 ease-in-out hover:bg-slate-400 hover:text-slate-100 hover:shadow-lg" />
        </form>
        <div class="bg-slate-500 w-[2px] h-[32px] rounded-lg"></div>
      <?php endif; ?>
      <button onclick="window.location.href='./libraries/logout.php';"
        class="bg-slate-300 rounded-lg p-2 text-slate-600 text-center transition-all duration-250 delay-0 ease-in-out hover:bg-slate-400 hover:text-slate-100 hover:shadow-lg">Logout</button>
    </div>
  </div>
</header>