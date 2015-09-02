Deploying Apache Tajo™ on Google Cloud Platform
===============================================

Apache Tajo
-----------

Apache Tajo is a robust big data relational and distributed data warehouse system for Apache Hadoop. Tajo is designed for low-latency and scalable ad-hoc queries, online aggregation, and ETL (extract-transform-load process) on large-data sets stored on HDFS (Hadoop Distributed File System) and other data sources. By supporting SQL standards and leveraging advanced database techniques, Tajo allows direct control of distributed execution and data flow across a variety of query evaluation strategies and optimization opportunities.

Getting Started
---------------

1. Install gcloud SDK

    https://cloud.google.com/sdk/
    
2. Install bdutil Tajo extension

    $ git clone -b tajo https://github.com/gruter/bdutil.git
    
3. Configure
   
    $ vi  bdutil_env.sh

    ```
    CONFIGBUCKET="your_bucket" 
    PROJECT="your_project_id" 
    GCE_ZONE="your_zone"
    ```
    
    $ vi extensions/tajo/tajo_env.sh
    
    ```
    TAJO_TARBALL_URI='gs://your_bucket/tajo-x.xx.x.tar.gz'
    TAJO_ROOT_DIR='gs://your_bucket/tajo'
    ```
    
4. Running with cloudSQL(optional)

    1. Create a cloudSQL instance
    
        $ gcloud sql instances create ``tajo-meta`` --assign-ip --authorized-networks 0.0.0.0/0 --region ``"asia-east1"`` --tier ``"D0"``
        
    2. Create a tajo user in cloudSQL.
    
    3. Create a tajo database in cloudSQL.
    
    4. Upload mysql-connector-java.jar to your google cloud storage bucket.
    
    5. configure tajo_env.sh
    
        $ vi extensions/tajo/tajo_env.sh
        
        ```
        # For catalog store. default is derby.
        CATALOG_ID='your_cloudSQL_account_id'
        CATALOG_PW='your_cloudSQL_account_passwd'
        CATALOG_CLASS='org.apache.tajo.catalog.store.MySQLStore'
        CATALOG_URI='jdbc:mysql://your_cloudSQL_host:3306/your_cloudSQL_databases?createDatabaseIfNotExist=true'

        # For tajo third party library directory(ex mysql-connector-java.jar)
        EXT_LIB='gs://your_bucket/ext_lib'
        ```

Basic Usage
-----------

Basic installation of [Apache tajo](http://tajo.apache.org/) with Hadoop on Google Cloud Platform.

    ./bdutil -e extensions/tajo/tajo_env.sh deploy

Or alternatively, using shorthand syntax:

    ./bdutil -e tajo deploy
    
Advanced Configuration
----------------------

Refer to Tajo configuration documents for advanced configuration. (http://tajo.apache.org/docs/current/configuration.html)

Status
------

This plugin is currently considered experimental and not officially supported.
Contributions are welcome.
