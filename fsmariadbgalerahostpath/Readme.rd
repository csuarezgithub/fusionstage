ioi
DockerFile Origen donde se inicia el contenedor con userid y groupid 27

FROM centos:centos7
MAINTAINER adfinis-sygroup.ch <info@adfinis-sygroup.ch>
LABEL io.k8s.description="MariaDB is a multi-user, multi-threaded SQL database server" \
      io.k8s.display-name="MariaDB 10.1" \
      io.openshift.expose-services="3306:mysql" \
      io.openshift.tags="database,mysql,mariadb10,rh-mariadb10"
EXPOSE 3306/tcp

COPY root/etc/yum.repos.d/mariadb.repo /etc/yum.repos.d/

RUN rpm --import https://yum.mariadb.org/RPM-GPG-KEY-MariaDB && \
    yum install -y \
      epel-release && \
    yum install -y \
      MariaDB-client \
      MariaDB-server \
      galera \
      which \
      socat \
      percona-xtrabackup \
      bind-utils \
      policycoreutils && \
    yum clean all
RUN echo '!include /etc/config/my_extra.cnf' >> /etc/my.cnf

COPY root /
RUN /usr/libexec/container-setup.sh

VOLUME ["/var/lib/mysql"]
USER 27:27
ENTRYPOINT ["/usr/bin/container-entrypoint.sh"]

Creación de Volumen Persistente hostpath

Nombre del Archivo:  galera-pv-host.yml
Link: 
Al kind: PersistentVolume se tiene que agregar un identificador en este caso es 
annotations:
       volume.beta.kubernetes.io/storage-class: "datadirmysql"


apiVersion: v1
kind: PersistentVolume
metadata:
   name: datadir-mysql-0
   annotations:
       volume.beta.kubernetes.io/storage-class: "datadirmysql"
spec:
 accessModes:
   - ReadWriteOnce
 capacity:
   storage: 2Gi
 hostPath:
   path: /data/datadir-mysql-0/
---

Para crear el volumen persistente se agrega el siguiente comando definiendo en que namespace  se debe crear el volumen persistente en este caso project-atp

x create -f galera-pv-host.yml -nproject-atp

Para verificar el el volumen persistente fue creado se ejecuta el siguiente comando

x describe pv

Name:           datadir-mysql-0
Labels:         <none>
StorageClass:   datadirmysql
Status:         Bound
Claim:          project-atp/datadir-mysql-0
Reclaim Policy: Retain
Access Modes:   RWO
Capacity:       2Gi
Message:
Source:
    Type:       HostPath (bare host directory volume)
    Path:       /data/datadir-mysql-0/
No events.
--------------------------
Name:           datadir-mysql-1
Labels:         <none>
StorageClass:   datadirmysql
Status:         Bound
Claim:          project-atp/datadir-mysql-2
Reclaim Policy: Retain
Access Modes:   RWO
Capacity:       2Gi
Message:
Source:
    Type:       HostPath (bare host directory volume)
    Path:       /data/datadir-mysql-1/
No events.
--------------------------

Name:           datadir-mysql-2
Labels:         <none>
StorageClass:   datadirmysql
Status:         Bound
Claim:          project-atp/datadir-mysql-1
Reclaim Policy: Retain
Access Modes:   RWO
Capacity:       2Gi
Message:
Source:
    Type:       HostPath (bare host directory volume)
    Path:       /data/datadir-mysql-2/
No events.

En el archivo tipo kind:StatefulSet en se debe agregar la nota para enlazar el volumen persistente ya creado en el apartado volumeClaimTemplates se debe especificar la nota

Archivo: galera_k8s_v1.6.yml
PersistentVolumeClaim es la solicitud de un usuario y reclama un volumen persistente

volumeClaimTemplates:
 - metadata:
     name: datadir
     namespace: project-atp
     labels:
       app: mysql
     annotations:
       volume.beta.kubernetes.io/storage-class: "datadirmysql"
   spec:
     accessModes: [ "ReadWriteOnce" ]
     resources:
       requests:
         storage: 2Gi



Una vez creado el pv y modificado el volumeClaimTemplates debemos revisar con que usuario está iniciando el contenedor

docker inspect 3e47a3914087

El contenedor está corriendo con el user id 27 como podemos ver en la imagen



Nos conectamos a los nodos donde esta corriendo el contenedor y con el usuario root y un chown recursivo añadiendo el userid y groupid 27 el contenedor puede escribir en la ruta.



node-ha-2449650:/data/datadir-mysql-0 # cd /data/
node-ha-2449650:/data # ls
datadir-mysql-0

node-8972780:/home/paas # cd /data/
node-8972780:/data # ls
datadir-mysql-2

paas@node-413-1941600:~> cd /data/
paas@node-413-1941600:/data> ls
datadir-mysql-1
paas@node-413-1941600:/data>


Ejemplo de como asignar userid y group id en un volumen persistente tipo hostpath
paas@node-413-1941600:/data> su
Password:
node-413-1941600:/data # chown -R 27:27 /data/datadir-mysql-1/
node-413-1941600:/data #
