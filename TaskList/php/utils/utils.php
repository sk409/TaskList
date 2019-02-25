<?php

function getTableNames($pdo) {
    $sql = "SHOW TABLES";
    $stm = $pdo->prepare($sql);
    $stm->execute();
    $results = $stm->fetchAll();
    $tableNames = array();
    foreach ($results as $result) {
        $tableNames[] = $result[0];
    }
    return $tableNames;
}

function getDataBaseNames($pdo) {
    $sql = "SHOW DATABASES";
    $stm = $pdo->prepare($sql);
    $stm->execute();
    $results = $stm->fetchAll();
    $dataBaseNames = array();
    foreach ($results as $result) {
        $dataBaseNames[] = $result[0];
    }
    return $dataBaseNames;
}

function getResultCode() {
    $url = "../json/ResultCode.json";
    $json = file_get_contents($url);
    return json_decode($json, true);
}

function filterInputs(int $type, array $names) {
    $filtered = [];
    foreach ($names as $name) {
        $filtered[$name] = (string)filter_input($type, $name);
    }
    return $filtered;
}