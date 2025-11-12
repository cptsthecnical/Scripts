<?php
// Instalación de PHP en Windows:
// ******************************
// 1 - Descarga PHP: desde windows.php.net - elige la versión Thread Safe zip.
// 2 - Extrae: por ejemplo en C:\php.
// 3 - Configura php.ini: copia php.ini-development como php.ini y edita si necesitas extensiones.
// 4 - Agrega a PATH: Panel de control → Sistema → Configuración avanzada → Variables de entorno → Path → Editar → Nuevo → C:\php
// 5 - Verifica: abre cmd y ejecuta: php -v

// Archivo de tareas
define('TASK_FILE', 'Task-Fenix41.json');
define('ARCHIVE_FILE', 'ashes.txt');

echo "\n";
echo "\n";
echo "> Metodología KANBAN para trabajar de manera individual.\n";

function loadTasks() {
    if (!file_exists(TASK_FILE)) {
        return [];
    }
    $json = file_get_contents(TASK_FILE);
    $tasks = json_decode($json, true);
    if (json_last_error() !== JSON_ERROR_NONE) {
        echo "Error leyendo el archivo JSON: " . json_last_error_msg() . "\n";
        // Mantener archivo original, no reemplazar
        return [];
    }

    // Asegurar que las tareas sean un array asociativo con padres
    if (!is_array($tasks) || array_values($tasks) === $tasks) {
        return [];
    }
    return $tasks;
}

function saveTasks($tasks) {
    // Hacer backup antes de guardar
    if (file_exists(TASK_FILE)) {
        copy(TASK_FILE, TASK_FILE . '.bak');
    }

    $json = json_encode($tasks, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
    if ($json === false) {
        echo "Error guardando tareas: " . json_last_error_msg() . "\n";
        return false;
    }

    file_put_contents(TASK_FILE, $json);
    return true;
}

function saveCompletedTasksToFile($tasks, $filename) {
    $completedTasks = [];
    foreach ($tasks as $parent => $taskList) {
        foreach ($taskList as $task) {
            if ($task['done']) {
                $completedTasks[] = "- " . $task['name'];
            }
        }
    }
    if (!empty($completedTasks)) {
        $date = date('Y-m-d H:i:s');
        $fileContent = "Tareas completadas (eliminadas el $date):\n" . implode("\n", $completedTasks) . "\n";
        file_put_contents($filename, $fileContent, FILE_APPEND);
    }
}

function showTasks($tasks) {
    echo "Lista de tareas:\n";
    if (empty($tasks)) {
        echo "No hay tareas.\n";
    } else {
        foreach ($tasks as $parent => $taskList) {
            echo "\n=====================================================\n";
            echo "[🐦🔥 $parent]:\n\n";
            foreach ($taskList as $index => $task) {
                $status = $task['done'] ? "[x]" : "[ ]";
                echo "$status " . ($index + 1) . ". " . $task['name'] . "\n";
            }
        }
    }
}

$tasks = loadTasks();

while (true) {
    try {
        echo "\nBienvenido al gestor de tareas!\n";
        showTasks($tasks);
        echo "\n";
        echo "___________           .__          _____ ____   \n";
        echo "\_   _____/___   ____ |__|__  ___ /  |  /_   |  \n";
        echo " |    __)/ __ \ /    \|  \  \/  //   |  ||   |  \n";
        echo " |     \|  ___/|   |  \  |>    </    ^   /   |  \n";
        echo " \___  /\____  >___|  /__/__/\_ \____   ||___|  \n";
        echo "     \/      \/     \/         \/    |__|       \n\n";

        // Menú
        echo "1.  Agregar una tarea \n";
        echo "2.  Crear un nuevo padre \n";
        echo "\033[31m3.  Borrar todas las tareas           ~ De manera irrecuperable. \033[0m\n";
        echo "\033[31m4.  Borrar un padre                   ~ De manera irrecuperable. \033[0m\n";
        echo "\033[31m5.  Borrar una tarea específica       ~ De manera irrecuperable. \033[0m\n";
        echo "\033[31m6.  Borrar tareas completadas [x]     ~ Guarda las tareas antiguas si es necesario. \033[0m\n";
        echo "\033[32m7.  Marcar una tarea como realizada \033[0m\n";
        echo "\033[33m8.  Quitar tarea como realizada \033[0m\n";
        echo "\033[33m9.  Renombrar un padre o una tarea \033[0m\n";
        echo "\033[33m10. Mover posición de una tarea \033[0m\n";
        echo "11. Ver tareas \n";
        echo "0. Salir \n";
        echo "\033[30;43m Selecciona una opción: \033[0m \n";

        $option = intval(trim(fgets(STDIN)));

        switch ($option) {
            case 1:
                if (empty($tasks)) {
                    echo "No hay padres disponibles. Crea uno primero.\n";
                    break;
                }
                echo "Selecciona el padre al que deseas asignar la tarea:\n";
                $parents = array_keys($tasks);
                foreach ($parents as $index => $parent)
                    echo ($index + 1) . ". $parent\n";
                $parentIndex = intval(trim(fgets(STDIN))) - 1;
                if (!isset($parents[$parentIndex])) {
                    echo "Selección no válida.\n";
                    break;
                }
                $parent = $parents[$parentIndex];

                echo "Escribe el nombre de la nueva tarea: ";
                $taskName = trim(fgets(STDIN));
                $tasks[$parent][] = ['name' => $taskName, 'done' => false];
                saveTasks($tasks);
                echo "Tarea agregada con éxito.\n";
                break;

            case 2:
                echo "Ingresa el nombre del nuevo padre: ";
                $parentName = trim(fgets(STDIN));
                if (!isset($tasks[$parentName])) {
                    $tasks[$parentName] = [];
                    saveTasks($tasks);
                    echo "Padre '$parentName' creado con éxito.\n";
                } else {
                    echo "Ese padre ya existe.\n";
                }
                break;

            case 3:
                $tasks = [];
                saveTasks($tasks);
                echo "Todas las tareas han sido eliminadas.\n";
                break;

            case 4:
                if (empty($tasks)) {
                    echo "No hay padres disponibles para borrar.\n";
                    break;
                }
                echo "Selecciona el padre a borrar:\n";
                $parents = array_keys($tasks);
                foreach ($parents as $index => $parent)
                    echo ($index + 1) . ". $parent\n";
                $parentIndex = intval(trim(fgets(STDIN))) - 1;
                if (!isset($parents[$parentIndex])) {
                    echo "Selección no válida.\n";
                    break;
                }
                $parent = $parents[$parentIndex];

                echo "¿Estás seguro? (s/n): ";
                $confirm = trim(fgets(STDIN));
                if (strtolower($confirm) === 's') {
                    unset($tasks[$parent]);
                    saveTasks($tasks);
                    echo "Padre y sus tareas eliminados.\n";
                } else {
                    echo "Operación cancelada.\n";
                }
                break;

            case 5:
                if (empty($tasks)) {
                    echo "No hay tareas para borrar.\n";
                    break;
                }
                echo "Selecciona el padre de la tarea a borrar:\n";
                $parents = array_keys($tasks);
                foreach ($parents as $index => $parent)
                    echo ($index + 1) . ". $parent\n";
                $parentIndex = intval(trim(fgets(STDIN))) - 1;
                if (!isset($parents[$parentIndex])) {
                    echo "Selección no válida.\n";
                    break;
                }
                $parent = $parents[$parentIndex];
                if (empty($tasks[$parent])) {
                    echo "No hay tareas en este padre.\n";
                    break;
                }

                echo "Selecciona la tarea a borrar:\n";
                foreach ($tasks[$parent] as $index => $task)
                    echo ($index + 1) . ". " . $task['name'] . "\n";
                $taskIndex = intval(trim(fgets(STDIN))) - 1;
                if (!isset($tasks[$parent][$taskIndex])) {
                    echo "Selección no válida.\n";
                    break;
                }
                array_splice($tasks[$parent], $taskIndex, 1);
                saveTasks($tasks);
                echo "Tarea eliminada con éxito.\n";
                break;

            case 6:
                echo "¿Guardar tareas completadas antes de borrarlas? (s/n): ";
                $saveOption = trim(fgets(STDIN));
                if (strtolower($saveOption) === 's') {
                    saveCompletedTasksToFile($tasks, ARCHIVE_FILE);
                    echo "Tareas guardadas.\n";
                }

                foreach ($tasks as $parent => &$taskList) {
                    $taskList = array_values(array_filter($taskList, fn($task) => !$task['done']));
                }
                saveTasks($tasks);
                echo "Tareas completadas eliminadas.\n";
                break;

            case 7:
            case 8:
                $markDone = $option === 7;
                if (empty($tasks)) {
                    echo "No hay tareas.\n";
                    break;
                }
                echo "Selecciona el padre de la tarea:\n";
                $parents = array_keys($tasks);
                foreach ($parents as $index => $parent)
                    echo ($index + 1) . ". $parent\n";
                $parentIndex = intval(trim(fgets(STDIN))) - 1;
                if (!isset($parents[$parentIndex])) {
                    echo "Selección no válida.\n";
                    break;
                }
                $parent = $parents[$parentIndex];
                if (empty($tasks[$parent])) {
                    echo "No hay tareas en este padre.\n";
                    break;
                }

                echo "Selecciona la tarea:\n";
                foreach ($tasks[$parent] as $index => $task)
                    echo ($index + 1) . ". " . $task['name'] . "\n";
                $taskIndex = intval(trim(fgets(STDIN))) - 1;
                if (!isset($tasks[$parent][$taskIndex])) {
                    echo "Selección no válida.\n";
                    break;
                }

                $tasks[$parent][$taskIndex]['done'] = $markDone;
                saveTasks($tasks);
                echo $markDone ? "Tarea marcada como realizada.\n" : "Tarea desmarcada.\n";
                break;

            case 9:
                echo "1. Renombrar tarea\n2. Renombrar padre\nSelecciona: ";
                $renameOption = intval(trim(fgets(STDIN)));
                if ($renameOption === 1) {
                    if (empty($tasks)) {
                        echo "No hay tareas.\n";
                        break;
                    }
                    echo "Selecciona el padre de la tarea:\n";
                    $parents = array_keys($tasks);
                    foreach ($parents as $index => $parent)
                        echo ($index + 1) . ". $parent\n";
                    $parentIndex = intval(trim(fgets(STDIN))) - 1;
                    if (!isset($parents[$parentIndex])) {
                        echo "Selección no válida.\n";
                        break;
                    }
                    $parent = $parents[$parentIndex];
                    if (empty($tasks[$parent])) {
                        echo "No hay tareas en este padre.\n";
                        break;
                    }

                    echo "Selecciona la tarea:\n";
                    foreach ($tasks[$parent] as $index => $task)
                        echo ($index + 1) . ". " . $task['name'] . "\n";
                    $taskIndex = intval(trim(fgets(STDIN))) - 1;
                    if (!isset($tasks[$parent][$taskIndex])) {
                        echo "Selección no válida.\n";
                        break;
                    }

                    echo "Nuevo nombre de la tarea: ";
                    $tasks[$parent][$taskIndex]['name'] = trim(fgets(STDIN));
                    saveTasks($tasks);
                    echo "Tarea renombrada.\n";
                } elseif ($renameOption === 2) {
                    if (empty($tasks)) {
                        echo "No hay padres.\n";
                        break;
                    }
                    echo "Selecciona el padre: ";
                    $parents = array_keys($tasks);
                    foreach ($parents as $index => $parent)
                        echo ($index + 1) . ". $parent\n";
                    $parentIndex = intval(trim(fgets(STDIN))) - 1;
                    if (!isset($parents[$parentIndex])) {
                        echo "Selección no válida.\n";
                        break;
                    }
                    $oldParentName = $parents[$parentIndex];

                    echo "Nuevo nombre del padre: ";
                    $newParentName = trim(fgets(STDIN));
                    if (isset($tasks[$newParentName])) {
                        echo "Ya existe un padre con ese nombre.\n";
                        break;
                    }

                    $tasks[$newParentName] = $tasks[$oldParentName];
                    unset($tasks[$oldParentName]);
                    saveTasks($tasks);
                    echo "Padre renombrado.\n";
                } else
                    echo "Opción no válida.\n";
                break;

            case 10:
                if (empty($tasks)) {
                    echo "No hay tareas disponibles.\n";
                    break;
                }
                echo "Selecciona el padre: ";
                $parents = array_keys($tasks);
                foreach ($parents as $index => $parent)
                    echo ($index + 1) . ". $parent\n";
                $parentIndex = intval(trim(fgets(STDIN))) - 1;
                if (!isset($parents[$parentIndex])) {
                    echo "Selección no válida.\n";
                    break;
                }
                $parent = $parents[$parentIndex];
                if (empty($tasks[$parent])) {
                    echo "No hay tareas en este padre.\n";
                    break;
                }

                echo "Selecciona la tarea a mover:\n";
                foreach ($tasks[$parent] as $index => $task)
                    echo ($index + 1) . ". " . $task['name'] . "\n";
                $taskIndex = intval(trim(fgets(STDIN))) - 1;
                if (!isset($tasks[$parent][$taskIndex])) {
                    echo "Selección no válida.\n";
                    break;
                }

                $taskToMove = $tasks[$parent][$taskIndex];
                array_splice($tasks[$parent], $taskIndex, 1);

                echo "Nueva posición:\n";
                foreach ($tasks[$parent] as $index => $task)
                    echo ($index + 1) . ". " . $task['name'] . "\n";
                echo (count($tasks[$parent]) + 1) . ". Última posición\n";

                $newPosition = intval(trim(fgets(STDIN))) - 1;
                if ($newPosition < 0)
                    $newPosition = 0;
                elseif ($newPosition > count($tasks[$parent]))
                    $newPosition = count($tasks[$parent]);

                array_splice($tasks[$parent], $newPosition, 0, [$taskToMove]);
                saveTasks($tasks);
                echo "Tarea movida.\n";
                break;

            case 11:
                break; // Ver tareas ya está implícito
            case 0:
                echo "Saliendo...\n";
                exit;
            default:
                echo "Opción no válida.\n";
                break;
        }
    } catch (Exception $e) {
        echo "Interrupción detectada. Guardando y saliendo...\n";
        saveTasks($tasks);
        exit;
    }
}
