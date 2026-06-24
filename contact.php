<?php
header('Content-Type: application/json; charset=utf-8');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false]);
    exit;
}

$nom      = trim($_POST['nom']        ?? '');
$email    = trim($_POST['email']      ?? '');
$tel      = trim($_POST['telephone']  ?? '');
$quantite = trim($_POST['quantite']   ?? '');
$message  = trim($_POST['commentaire'] ?? '');

if (empty($nom) || empty($email) || !filter_var($email, FILTER_VALIDATE_EMAIL)) {
    http_response_code(400);
    echo json_encode(['success' => false]);
    exit;
}

$to      = 'contact@madagascar-vanille.com';
$subject = '=?UTF-8?B?' . base64_encode('Demande de devis — Madagascar Vanilla') . '?=';

$body  = "Nom : $nom\n";
$body .= "Email : $email\n";
$body .= "Téléphone : " . ($tel      ?: '—') . "\n";
$body .= "Quantité : "  . ($quantite ?: '—') . "\n\n";
$body .= "Message :\n"  . ($message  ?: '—');

$headers  = "MIME-Version: 1.0\r\n";
$headers .= "Content-Type: text/plain; charset=UTF-8\r\n";
$headers .= "From: Madagascar Vanilla <noreply@madagascar-vanille.com>\r\n";
$headers .= "Reply-To: $email\r\n";

$sent = mail($to, $subject, $body, $headers);

echo json_encode(['success' => (bool)$sent]);
