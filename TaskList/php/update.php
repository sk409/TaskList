<?php
require_once("utils/utils.php");
$parameters = filterInputs(INPUT_POST, ["userName", "password", "databaseName", "databaseHost", "tableName", "id", "title", "contents", "date"]);
$user = $parameters[ "userName"];
$password = $parameters["password"];
$dbname = $parameters["databaseName"];
$host = $parameters["databaseHost"];
$table = $parameters["tableName"];
$id = $parameters["id"];
$title = $parameters["title"];
$contents = $parameters["contents"];
$date = $parameters["date"];
$dsn = "mysql:host={$host};dbname={$dbname};charset=utf8";
try {
    $options = [PDO::ATTR_EMULATE_PREPARES => false, PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION];
    $pdo = new PDO($dsn, $user, $password, $options);
    $sql = "UPDATE {$table} SET title=?, contents=?, date=? WHERE id=?";
    $stm = $pdo->prepare($sql);
    $stm->bindValue(1, $title, PDO::PARAM_STR);
    $stm->bindValue(2, $contents, PDO::PARAM_STR);
    $stm->bindValue(3, $date, PDO::PARAM_STR);
    $stm->bindValue(4, $id, PDO::PARAM_INT);
    $stm->execute();
    $pdo = null;
    print("OK");
} catch (Exception $e) {
    print("ERROR");
}
?>