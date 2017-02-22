# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# precompile the core manifests
Rails.application.config.assets.precompile += %w(core.js core.css)

# precompile the individual javascript for each page
# todo: figure out why index.js does not get caught in pages/*.js
Rails.application.config.assets.precompile += %w(pages/*.js pages/index.js)

# precompile the individual css for each page
Rails.application.config.assets.precompile += %w(pages/*.css pages/index.css)

# precompile the css and js for the user pages (password reset, etc.)
Rails.application.config.assets.precompile += %w( users/*.css )
Rails.application.config.assets.precompile += %w( users/*.js )
