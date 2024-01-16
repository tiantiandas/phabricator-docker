<?php
// We trust the answer of nginx.
$_SERVER['REMOTE_ADDR'] = $_SERVER['HTTP_X_FORWARDED_FOR'];

// Phabricator uses the HTTPS variable to determine the protocol.
if ($_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https') {
    $_SERVER['HTTPS'] = true;
}