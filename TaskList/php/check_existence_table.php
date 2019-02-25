<?php
require_once("utils/utils.php");
$parameters = filterInputs(INPUT_GET, ["userName", "password", "databaseHost", "databaseName", "tableName"]);
$user = $parameters["userName"];
$password = $parameters["password"];
$dbname = $parameters["databaseName"];
$host = $parameters["databaseHost"];
$table = $parameters["tableName"];
$dsn = "mysql:host={$host};dbname={$dbname};charset=utf8";
try {
    $options = [PDO::ATTR_EMULATE_PREPARES => false, PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION];
    $pdo = new PDO($dsn, $user, $password, $options);
    $tableNames = getTableNames($pdo);
    if (in_array($table, $tableNames)) {
        print("true");
    } else {
        print("false");
    }
} catch (Exception $e) {
    print("エラーが発生しました。");
}

