<?php
session_start();
require "config/config.php";

if ($_SERVER["REQUEST_METHOD"] == "POST") {

    $email = trim($_POST["email"]);
    $password = trim($_POST["password"]);

    // Check if user exists
    $stmt = $pdo->prepare("SELECT * FROM users WHERE email = ?");
    $stmt->execute([$email]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($user) {

        // Verify password
        if (password_verify($password, $user["password"])) {

            // Store session variables
            $_SESSION["user_id"] = $user["id"];
            $_SESSION["full_name"] = $user["full_name"];
            $_SESSION["role"] = $user["role"];

            // Redirect based on role
            if ($user["role"] == "admin") {
                header("Location: ../site/admin_pot/admin_dashboard.html");
            } elseif ($user["role"] == "seller") {
                header("Location: ../site/seller_pot/seller_dashboard.html");
            } else {
                header("Location: ../site/buyer_pot/buyer_dashboard.html");
            }

            exit();

        } else {
            echo "Invalid password!";
        }

    } else {
        echo "Email not found!";
    }
}
?>