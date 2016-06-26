### When i try to connect my rails app to mongo lab, i get a trouble.
In config/mongoid.yml
```yaml
  development:
  sessions:
    default:
      username: <user>
      password: <pass>
      database: <data>
      hosts:
        - ds023xxx.mlab.com
      port: 23xxx
```
and i can't access to my database
```shell
  oped::Errors::ConnectionFailure: Could not connect to a primary node for replica set 
  #<Moped::Cluster:30329540 @seeds=[<Moped::Node resolved_address="104.197.61.113:27017">]>
```
Fixed
```yaml
  development:
  sessions:
    default:
      username: <user>
      password: <pass>
      database: <data>
      hosts:
        - ds023xxx.mlab.com:23xxx
```
it worked

so stupid
