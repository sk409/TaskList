<?php
require_once("utils/utils.php");
$queries = filterInputs(INPUT_POST, ["userName", "password", "databaseName", "databaseHost", "tableName", "title", "contents", "date"]);
$user = $queries["userName"];
$password = $queries["password"];
$dbname = $queries["databaseName"];
$host = $queries["databaseHost"];
$tbname = $queries["tableName"];
$title = $queries["title"];
$contents = $queries["contents"];
$date = $queries["date"];
$dsn = "mysql:host={$host};dbname={$dbname};charset=utf8";
try {
    $options = [PDO::ATTR_EMULATE_PREPARES => false , PDO::ATTR_ERRMODE => PDO :: ERRMODE_EXCEPTION];
    $pdo = new PDO($dsn, $user, $password, $options);
    $sql = "INSERT INTO {$tbname}(title, contents, date) VALUES(?, ?, ?)";
    $stm = $pdo->prepare($sql);
    $stm->bindValue(1, $title, PDO::PARAM_STR);
    $stm->bindValue(2, $contents, PDO::PARAM_STR);
    $stm->bindValue(3, $date, PDO::PARAM_STR);
    $stm->execute();
    $pdo = null;
    print("OK");
} catch (Exception $e) {
    print("ERROR");
}

