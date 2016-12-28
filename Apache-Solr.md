# Solr-on-tomcat

$ sudo apt-get update

$ sudo apt-get install wget

$ wget http://mirrors.digipower.vn/apache/tomcat/tomcat-8/v8.0.21/bin/apache-tomcat-8.0.21.tar.gz

$ wget http://mirrors.digipower.vn/apache/lucene/solr/4.10.2/solr-4.10.2.tgz

$ tar -xzvf apache-tomcat-8.0.21.tar.gz

$ mv apache-tomcat-8.0.21 tomcat-8.0.21

$ tar xzvf solr-4.10.2.tgz

<option your any version>
    
#Copy and rename files from solr foder to tomcat foder

$ cp solr-4.10.2/dist/solr-4.10.2.war tomcat-8.0.21/webapps/solr.war

$ cp -r solr-4.10.2/example/multicore tomcat-8.0.21/solr

$ cp -r solr-4.10.2/example/solr/collection1/conf/* tomcat-8.0.21/solr/core0/conf/

$ cp -r solr-4.10.2/example/solr/collection1/conf/* tomcat-8.0.21/solr/core1/conf/

$ cp -r solr-4.10.2/dist/ solr-4.10.2/contrib/ -t tomcat-8.0.21/

$ cp solr-4.10.2/example/lib/ext/* tomcat-8.0.21/lib/

$ cp solr-4.10.2/example/resources/log4j.properties tomcat-8.0.21/lib/

# Setup EVN

$ sudo apt-get install openjdk-7-jdk

$ sudo update-alternatives --config java

$ export JAVA_OPTS="-Dsolr.solr.home=/path/to/home/solr/"

# First Time run

$ tomcat-8.0.21/bin/startup.sh

$ vim tomcat-8.0.21/webapps/solr/WEB-INF/web.xml

    you must run before add
    umcomment in web.xml and change your sorl path
    <env-entry>
       <env-entry-name>solr/home</env-entry-name>
       <env-entry-value>"your_home_solr"</env-entry-value>
       <env-entry-type>java.lang.String</env-entry-type>
    </env-entry>
    
Note: "your_home_solr" in 'tomcat-8.0.21/solr' change if your version is diffirent 

# Add lib file to solrconfig.xml

 Add file "mysql-connector-java-5.1.36-bin.jar" to  tomcat-8.0.21/lib

 In home 
 
   $ wget https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.36.tar.gz
   
   $ tar xzvf mysql-connector-java-5.1.36.tar.gz
   
   $ mv  mysql-connector-java-5.1.36.tar/mysql-connector-java-5.1.36-bin.jar  tomcat-8.0.21/lib/mysql-connector-java-5.1.36-bin.jar
   
 In dir tomcat-8.0.21/solr/
 
 $ ls
 
 and you see 
 
    README.txt  core0  core1  exampledocs  multicore  solr.xml  zoo.cfg
    
 If you use core0 
 
 $ vim tomcat-8.0.21/solr/core0/conf/solrconfig.xml  

 Add lines
 
    <lib dir="/tomcat-8.0.21/dist" regex="solr-dataimporthandler-4.10.2.jar" />
    <lib dir="/tomcat-8.0.21/dist" regex="solr-dataimporthandler-extras-4.10.2.jar" />
    <lib dir="../../../lib" regex="mysql-connector-java-5.1.36-bin.jar" />
#Now restart tomcat and done
 $ tomcat-8.0.21/bin/shutdown.sh
 
 $ tomcat-8.0.21/bin/startup.sh
 
 http://localhost:8080/solr/
  
if work is done else ask google :)

#RequestHandle

 $ vim tomcat-8.0.21/solr/core0/conf/solrconfig.xml 
 
    Add this lines UNDER 
     <requestHandler name="/dataimport" class="org.apache.solr.handler.dataimport.DataImportHandler">
      <lst name="defaults">
        <str name="config">data-config.xml</str>
      </lst>
    </requestHandler>
    
    Create and edit data-config.xml in conf/
    
    With Mysql(change your Database url,user and pass)
    <dataConfig>
        <dataSource driver="org.hsqldb.jdbcDriver" url="jdbc:hsqldb:/temp/example/ex" user="sa" password="" />
        <document name="products">
            <entity name="item" query="select * from item">
                <field column="ID" name="id" />
                <field column="NAME" name="name" />
            </entity>
        </document>
    </dataConfig>
    
    Else if  With MongoDB:

    <?xml version="1.0" encoding="UTF-8" ?>
    <dataConfig>
         <dataSource name="MyMongo" type="MongoDataSource" database="[db_name]" host="[host]" port="[port]"/>
         <document name="Products">
             <entity processor="MongoEntityProcessor" 
                     query="{}" 
                     collection="[collection_name]" 
                     datasource="MyMongo" 
                     transformer="MongoMapperTransformer" >
                 <field column="title"           name="title"       />
                 <field column="description"     name="description" />
             </entity>
         </document>
    </dataConfig>
Finish, and you can use solr on tomcat now!

# Solr with Ruby on Rails, easy
    Basic query Solr-ruby
    Add gem 'solr-ruby' to file Gemfile
    
        gem 'solr-ruby'
     
    Set config in config/environments/development.rb or config/environments/production.rb
        ProjectApp::Application.configure do
            .......
            config.solr_host = "http://localhost:8080/apache-solr-3.6.2" 
            .......
            end
        
    Add require 'solr' to file app/controllers/application_controller.rb

        require 'solr'
        class ApplicationController < ActionController::Base
          .......
        end
    
     Using To use it in controllers, call connect to server Solr:

        class NameController < ApplicationController
          .......
          def search(keyword)
            @solr = Solr::Connection.new(Rails.configuration.solr_host.to_s, :autocommit => :on )
            query = "((name:#{keyword} OR description:#{keyword}))" 
            select_obj = Solr::Request::Select.new(nil, {'q' => query})
            # Total result
            # @total_result = @solr.send(select_obj).data['response']['numFound']
            # Value
            # @solr.send(select_obj).data['response']
            # Return hash
            @solr.send(select_obj)
          end
          ........
        end
 Way 2 : RSorl gem 
 
    https://github.com/rsolr/rsolr
