<?php
require_once "../config/db.php";

$data = json_decode(file_get_contents("php://input"), true);
$email = $data['email'];
$password = $data['password'];

$stmt = $conn->prepare("SELECT * FROM users WHERE email = ?");
$stmt->execute([$email]);
$user = $stmt->fetch(PDO::FETCH_ASSOC);

if($user && password_verify($password, $user['password'])) {
    // Generate simple token (for demonstration, can use JWT)
    $token = base64_encode($user['id'] . ":" . time());
    echo json_encode(["status" => "success", "token" => $token, "user" => $user]);
} else {
    echo json_encode(["status" => "error", "message" => "Invalid credentials"]);
}
?>
