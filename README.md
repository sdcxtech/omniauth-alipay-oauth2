omniauth-alipay-oauth2
===============

Alipay OAuth2 Strategy for OmniAuth.

Support connecting Alipay account to third-party APP and website. 
Read the Alipay docs for more details: 
[App支付宝登录](https://docs.open.alipay.com/218#), [网站支付宝登录](https://docs.open.alipay.com/263)

## Installing

Add to your `Gemfile`:

```ruby
gem 'omniauth-alipay-oauth2', require: 'omniauth-alipay'
```

Then `bundle install`.

## Usage

Adding the middleware to a Rails app in `config/initializers/omniauth.rb`:

```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :alipay, 'your_app_id', File.read('rsa_private_key.pem'), 'alipay_public_key'
end
```

Read the OmniAuth docs for detailed instructions: https://github.com/intridea/omniauth.

## Sandbox

Developing in sandbox environment. See: [关于沙箱](https://docs.open.alipay.com/263/105809#s4)

```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :alipay, 'your_app_id', File.read('rsa_private_key.pem'), 'alipay_public_key',
            client_options: {
              authorize_url: 'https://openauth.alipaydev.com/oauth2/publicAppAuthorize.htm',
              token_url: 'https://openauth.alipaydev.com/oauth2/token',
              url: 'https://openapi.alipaydev.com/gateway.do'
            }
end
```
