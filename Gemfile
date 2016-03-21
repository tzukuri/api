source 'https://rubygems.org'

gem 'rails', '4.2.3'
gem 'pg'

# assets
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder', '~> 2.0'

# uploads
gem 'paperclip', '~> 4.3'

# admin
gem 'activeadmin', '~> 1.0.0.pre1'

# permissions
gem 'devise'
gem 'draper', '~> 1.3'
gem 'omniauth', '~> 1.2.2'

# security
gem 'ruby_rncryptor', '~> 3.0.0'
gem 'bcrypt', '~> 3.1.7'

# queue
gem 'que', '~> 0.11.4'
gem 'que-web', '~> 0.4.0'
gem 'lowdown', '~> 0.3.1'

#gem 'appsignal', '~> 0.12.rc'

group :doc do
    gem 'sdoc', '~> 0.4.0'
end

group :development, :test do
    gem 'byebug'
    gem 'web-console', '~> 2.0'
    #gem 'spring' # until #696 is fixed: https://github.com/celluloid/celluloid/issues/696
end

group :test do
    gem 'minitest-reporters', '1.0.5'
    gem 'mini_backtrace',     '0.1.3'
    gem 'guard-minitest',     '2.3.1'
end

group :production do
    gem 'therubyracer', platforms: :ruby
end
