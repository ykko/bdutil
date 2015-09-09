Deploying Apache Tajo™ on Google Cloud Platform
===============================================

Apache Tajo
-----------

Apache Tajo is a robust big data relational and distributed data warehouse system. Dubbed “an SQL-on-Hadoop solution”, Tajo is optimized for running low-latency, scalable ad-hoc queries and ETL jobs on large-data sets stored on both HDFS and other data sources including Amazon S3 and Google Cloud Storage. By supporting SQL standards and leveraging advanced database techniques, Tajo brings together the latest advances in distributed processing and query optimization, delivering enterprise-grade performance on both routine and massive data sets. With its ability to support both interactive analysis and complex ETL in a single solution, Tajo is a powerful open-source alternative to proprietary data warehousing solutions. 
+This documents explains how to setup Tajo cluster on Google Cloud Platform using bdutil.

Getting Started
---------------

1. Install gcloud SDK

    https://cloud.google.com/sdk/
    
2. Install bdutil Tajo extension

    $ git clone -b tajo https://github.com/gruter/bdutil.git
    
3. Configure
   
    $ vi  bdutil_env.sh

    ```
    CONFIGBUCKET="YOUR_BUCKET" 
    PROJECT="YOUR_PROJECT_ID" 
    GCE_ZONE="YOUR_ZONE"
    
    # change it to your instance type.
    GCE_MACHINE_TYPE='n1-standard-4'  
    
    # You can specify different instance type for master node. Otherwise, leave it blank.
    GCE_MASTER_MACHINE_TYPE='n1-standard-2'    

    # number of worker nodes 
    NUM_WORKERS=2
    ```
    
    $ vi extensions/tajo/tajo_env.sh
    
    ```
    # path to tajo tarball. eg. gs://tajo_release/tajo-0.11.0-SNAPSHOT.tar.gz
    TAJO_TARBALL_URI='gs://PATH_TO_TAJO_TARBALL/tajo-x.xx.x.tar.gz'
    ```
    
4. Using cloudSQL for Tajo meta store (optional)
    
    By default, Tajo stores its meta data in built-in Derby database in Tajo master node. Since it is ephemeral storage, so you'd better use it for test purpose only. 
    For continuous analysis work, using permanent meta store such as cloudSQL is strongly recommended.

    1. Set CLOUD_SQL_INSTANCE_ID.
       - ID of cloud sql instance.
       - If you have cloud sql instance, Set that instance Id or Set the new instance Id that will create.
       - If not exist cloud sql instance correspond this id, create new cloudSQL instance automatically as this id.
       - Empty this value is used derby for catalog store.
       - $ vi extensions/tajo/tajo_env.sh
       
       ```
       CLOUD_SQL_INSTANCE_ID=tajo-meta
       ```

Deployment
----------

To deploy Tajo:

    ./bdutil -f -e extensions/tajo/tajo_env.sh deploy

Or you can use shorthand syntax instead:

    ./bdutil -f -e tajo deploy
    
Destroy
-------

To delete Tajo:

    ./bdutil -f -e extensions/tajo/tajo_env.sh delete

Or you can use shorthand syntax instead:

    ./bdutil -f -e tajo delete

Basic Usage
-----------

By default, Tajo install directory is /home/hadoop/tajo-install. 

Run Tajo command line shell (tsql):

    tsql 
    
To stop and start Tajo daemon (Should run as "hadoop" user):

    stop-tajo.sh 
    start-tajo.sh

To check Tajo status, see Tajo web UI in your browser: 

    http://TAJO_MASTER_NODE_IP:26080/

To connect Tajo from your desktop (eg. via SQL workbench tools), be sure to open Tajo JDBC port 26002.
    
Advanced Configuration
----------------------

Refer to Tajo configuration documents for advanced configuration. (http://tajo.apache.org/docs/current/configuration.html)

Status
------

This plugin is currently considered experimental and not officially supported.
Contributions are more than welcome.

