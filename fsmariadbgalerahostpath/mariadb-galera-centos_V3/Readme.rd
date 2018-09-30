La imagen se crea con usuario root y se modifican los siguientes parametros

file: root/usr/bin/container-entrypoint.sh
# Run mysqld
exec mysqld --user=root

file:/root/usr/share/container-scripts/mysql/configure-mysql.sh

mysqld --user=root --skip-networking --socket=/var/run/mysql/mysql-init.sock --wsrep_on=OFF &
pid="$!"



mysql 

Database changed
MariaDB [test]> show variables like '%conn%';
+-----------------------------------------------+-------------------+
| Variable_name                                 | Value             |
+-----------------------------------------------+-------------------+
| character_set_connection                      | latin1            |
| collation_connection                          | latin1_swedish_ci |
| connect_timeout                               | 10                |
| default_master_connection                     |                   |
| extra_max_connections                         | 1                 |
| init_connect                                  |                   |
| max_connect_errors                            | 100               |
| max_connections                               | 151               |
| max_user_connections                          | 0                 |
| performance_schema_session_connect_attrs_size | -1                |
+-----------------------------------------------+-------------------+
10 rows in set (0.01 sec)

Para setear el valor max_connect_errors se debe modificar el archivo server.cnf
[mysqld]
datadir = /var/lib/mysql
ignore_db_dirs=lost+found
socket = /var/run/mysql/mysql.sock
skip-name-resolve
max_connections = 1000

MariaDB [test]> 


MariaDB [(none)]> use mysql
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
MariaDB [mysql]> show global variables like "skip%";
+-----------------------+-------+
| Variable_name         | Value |
+-----------------------+-------+
| skip_external_locking | ON    |
| skip_name_resolve     | OFF   |
| skip_networking       | OFF   |
| skip_show_database    | OFF   |
+-----------------------+-------+
4 rows in set (0.00 sec)

Revisar cuantos nodos tiene el cluster

MariaDB [(none)]> SHOW STATUS LIKE 'wsrep_cluster_size';
+--------------------+-------+
| Variable_name      | Value |
+--------------------+-------+
| wsrep_cluster_size | 3     |
+--------------------+-------+
1 row in set (0.01 sec)


