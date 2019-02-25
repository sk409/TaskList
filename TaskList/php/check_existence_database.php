<?php
require_once("utils/utils.php");
$parameters = filterInputs(INPUT_GET, ["userName", "password", "databaseHost", "databaseName"]);
$user = $parameters["userName"];
$password = $parameters["password"];
$host = $parameters["databaseHost"];
$dbname = $parameters["databaseName"];
$dsn = "mysql:host={$host};charset=utf8";
try {
    $options = [PDO::ATTR_EMULATE_PREPARES => false, PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION];
    $pdo = new PDO($dsn, $user, $password, $options);
    $dataBaseNames = getDataBaseNames($pdo);
    if (in_array($dbname, $dataBaseNames)) {
        print("true");
    }else {
        print("false");
    }
} catch (Exception $e) {
    print("ERROR");
}