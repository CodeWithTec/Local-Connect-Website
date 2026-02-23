<?php
require "config/config.php";

if ($_SERVER["REQUEST_METHOD"] == "POST") {

    // Collect form data
    $fname = trim($_POST["fname"]);
    $lname = trim($_POST["lname"]);
    $email = trim($_POST["email"]);
    $phone = trim($_POST["phone"]);
    $role = trim($_POST["role"]);
    $password = trim($_POST["password"]);
    $cpassword = trim($_POST["cpassword"]);

    // Combine first + last name
    $full_name = $fname . " " . $lname;

    // Password match check
    if ($password !== $cpassword) {
        die("Passwords do not match!");
    }

    // Check if email already exists
    $check = $pdo->prepare("SELECT id FROM users WHERE email = ?");
    $check->execute([$email]);

    if ($check->rowCount() > 0) {
        die("Email already registered!");
    }

    // Hash password
    $hashedPassword = password_hash($password, PASSWORD_DEFAULT);

    // Insert user
    $sql = "INSERT INTO users (first_name, last_name, email, password, phone, role)
            VALUES (?, ?, ?, ?, ?, ?)";

    $stmt = $pdo->prepare($sql);

    if ($stmt->execute([$fname, $lname, $email, $hashedPassword, $phone, $role])) {
        echo "Registration successful!";
        // header("Location: ../login.html"); // optional redirect
    } else {
        echo "Something went wrong!";
    }
}
?>