<?php
require_once("utils/utils.php");
$queries = filterInputs(INPUT_GET, ["userName", "password", "databaseName", "tableName", "databaseHost", "title", "contents"]);
$user = $queries["userName"];
$password = $queries["password"];
$dbname = $queries["databaseName"];
$tbname = $queries["tableName"];
$host = $queries["databaseHost"];
$title = $queries["title"];
$contents = $queries["contents"];
$dsn = "mysql:host={$host};dbname={$dbname};charset=utf8";
try {
    $options = [PDO::ATTR_EMULATE_PREPARES=>false, PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION];
    $pdo = new PDO($dsn, $user, $password, $options);
    $sql =  "SELECT * 
    FROM {$tbname}
    WHERE title LIKE ? AND contents LIKE ?
    ORDER BY date";
    $stm = $pdo->prepare($sql);
    $stm->bindValue(1, "%" . $title . "%", PDO::PARAM_STR);
    $stm->bindValue(2, "%" . $contents . "%", PDO::PARAM_STR);
    $stm->execute();
    $result = $stm->fetchAll(PDO::FETCH_ASSOC);
    print(json_encode($result));
} catch (Exception $e) {
    print("ERROR");
}