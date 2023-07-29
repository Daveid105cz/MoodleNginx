<?php  // Moodle configuration file


unset($CFG);
global $CFG;
$CFG = new stdClass();

$CFG->dbtype    = 'mariadb';
$CFG->dblibrary = 'native';
$CFG->dbhost    = 'moodle_database';
$CFG->dbname    = 'moodle';
$CFG->dbuser    = 'moodle_user';
$CFG->dbpass    = 'password';
$CFG->prefix    = 'mdl_';
$CFG->dboptions = array (
  'dbpersist' => 0,
  'dbport' => '',
  'dbsocket' => '',
  'dbcollation' => 'utf8mb4_unicode_ci',
);

$CFG->wwwroot   = 'https://localhost';
$CFG->dataroot  = '/moodledata';
$CFG->admin     = 'admin';

$CFG->directorypermissions = 0777;
$CFG->passwordsaltmain = 'riLm9qKgpU<Fxv9?}gB7^C_h[td+zk';

$CFG->debug = (E_ALL | E_STRICT);

require_once(__DIR__ . '/lib/setup.php');

// There is no php closing tag in this file
// it is intentional because it prevents trailing whitespace problems!