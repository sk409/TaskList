<?php
require_once("utils/utils.php");
$parameters = filterInputs(INPUT_POST, ["userName", "password", "databaseName", "databaseHost", "tableName", "id"]);
$user = $parameters["userName"];
$password = $parameters["password"];
$dbname = $parameters["databaseName"];
$host = $parameters["databaseHost"];
$table = $parameters["tableName"];
$id = $parameters["id"];
$dsn = "mysql:host={$host};dbname={$dbname};charset=utf8";
try {
    $options = [PDO::ATTR_EMULATE_PREPARES => false, PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION];
    $pdo = new PDO($dsn, $user, $password, $options);
    $sql = "DELETE FROM {$table} WHERE id=?";
    $stm = $pdo->prepare($sql);
    $stm->bindValue(1, $id, PDO::PARAM_INT);
    $stm->execute();
    $pdo = null;
    print("OK");
} catch (Exception $e) {
    print($e->getMessage());
    print("ERROR");
}
