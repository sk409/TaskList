<?php
require_once("utils/utils.php");
$parameters = filterInputs(INPUT_POST, ["userName", "password", "databaseName", "databaseHost", "tableName"]);
$user = $parameters["userName"];
$password = $parameters["password"];
$dbname = $parameters["databaseName"];
$table = $parameters["tableName"];
$host = $parameters["databaseHost"];
$dsn = "mysql:host={$host};dbname={$dbname};charset=utf8";
try {
    $options = [PDO::ATTR_EMULATE_PREPARES => false, PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION];
    $pdo = new PDO($dsn, $user, $password, $options);
    $sql = "CREATE TABLE {$table}(
            id INT UNSIGNED AUTO_INCREMENT NOT NULL PRIMARY KEY,
            title VARCHAR(40) NOT NULL,
            contents VARCHAR(1024) NOT NULL,
            date DATETIME NOT NULL
            )";
    $stm = $pdo->query($sql);
    print("OK");
} catch (Exception $e) {
    //print("ERROR");
    print($e->getMessage());
}
