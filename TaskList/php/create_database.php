<?php
require_once("utils/utils.php");
$parameters = filterInputs(INPUT_POST, ["databaseName", "userName", "password", "databaseHost"]);
$user = $parameters["userName"];
$password = $parameters["password"];
$host = $parameters["databaseHost"];
$dbname = $parameters["databaseName"];
$dsn = "mysql:host={$host};charset=utf8";
try {
    $options = [PDO::ATTR_EMULATE_PREPARES => false , PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION];
    $pdo = new PDO($dsn, $user, $password, $options);
    $sql = "CREATE DATABASE {$dbname}";
    $stm = $pdo->query($sql);
    print("OK");
} catch (Exception $e) {
    print("ERROR");
}