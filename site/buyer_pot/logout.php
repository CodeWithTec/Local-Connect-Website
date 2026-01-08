<?php
// Start the session
session_start();

// Unset all session variables
$_SESSION = [];

// Destroy the session
session_destroy();

// Optional: Delete session cookie (extra security)
if (ini_get("session.use_cookies")) {
    $params = session_get_cookie_params();
    setcookie(
        session_name(),
        '',
        time() - 42000,
        $params["path"],
        $params["domain"],
        $params["secure"],
        $params["httponly"]
    );
}

// Return JSON response (for AJAX)
// echo json_encode([
//     "status" => "success",
//     "message" => "Logged out successfully"
// ]);

// OR redirect to login page (uncomment if needed)
 header("Location: ../login.html");
// exit;
?>
