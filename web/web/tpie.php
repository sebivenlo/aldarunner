<?php
require_once 'Pie.php';
/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

$pi= new Pie(["passed","failed","errors","ignored","todo"], ["#0f0","#ff0","#ff0", "#aaa", "#606"]);

echo $pi->render([20,30,2,0,16])."\n";
