# td-agebt v4

## test

```
cat << EOT >> /var/log/ruby_on_rails.log
Started GET "/users/123/" for 127.0.0.1 at 2020-10-03 15:30:11 +0900
Processing by UsersController#show as HTML
  Parameters: {"user_id"=>"123"}
  Rendered users/show.html.erb within layouts/application (0.3ms)
Completed 200 OK in 4ms (Views: 3.2ms | ActiveRecord: 0.0ms)
EOT
```
