### my bad
```ruby
  service = Google::Apis::DriveV3::DriveService.new
  service.client_options.application_name = APPLICATION_NAME
  service.authorization = authorize

  video = Google::Apis::DriveV3::File::VideoMediaMetadata.new
  upsource = ''
  service.create_file(video , upload_source:upsource, content_type: 'video/mp4')
  
```
when I read and upload a large file to Google Drive API and the computer by cursing at me

```
/usr/local/rvm/rubies/ruby-2.3.0/lib/ruby/2.3.0/openssl/buffering.rb:322:in 
`syswrite': execution expired (Google::Apis::TransmissionError)
```
### my resolve
I try to fix it. search and find some way, i choose one.
```ruby
service = Google::Apis::DriveV3::DriveService.new.tap do |client| 
  client.request_options.timeout_sec = 3600
  client.request_options.open_timeout_sec = 3600
  client.request_options.retries = 3
end
service.client_options.application_name = APPLICATION_NAME
service.authorization = authorize

video = Google::Apis::DriveV3::File::VideoMediaMetadata.new
upsource = '
service.create_file(video , upload_source:upsource, content_type: 'video/mp4')
```
### I passed it!
