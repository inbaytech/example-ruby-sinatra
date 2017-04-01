# Ruby/Sinatra example of idQ Authentication

This repository demonstrates how to integrate idQ authentication into your Ruby/Sinatra web application.

## Prerequisites
1. You need to have an idQ Developer account (https://beta.idquanta.com)
2. Login to your Account Portal and issue OAuth2 credentials for the demo app. See <https://docs.idquanta.com> for instructions on issuing OAuth2 credentials.
3. Specify http://127.0.0.1:8123/oauthcallback as the Callback URL when creating your OAuth2 credentials.


## Usage
1. Clone this repository
2. Configure your OAuth2 Credentials in `app.rb`

```ruby
@idq = IdQClient.new('YOUR_CLIENT_ID',
                     'YOUR_CLIENT_SECRET',
                     'http://127.0.0.1:8123/oauthcallback'
)
```

3. Install dependencies `bundle install`
4. Start the application `./run.sh`
5. Navigate to http://localhost:8123 and try to access the Secure Page
