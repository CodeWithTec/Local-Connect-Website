<?php

$host = "localhost";
$dbname = "ecommerce_db";
$username = "root";
$password = "";

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8", $username, $password);
    
    // Set error mode
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // echo "Database connected successfully";

} catch(PDOException $e) {
    die("Connection failed: " . $e->getMessage());
}