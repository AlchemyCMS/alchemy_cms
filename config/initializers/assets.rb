# Add Alchemy assets for precompiling
Rails.application.config.assets.precompile += [
  'alchemy/alchemy.js',
  'alchemy/alchemy-logo.svg',
  'alchemy/favicon.ico',
  'alchemy/preview.js',
  'alchemy/admin.css',
  'alchemy/menubar.css',
  'alchemy/menubar.js',
  'alchemy/print.css',
  'alchemy/welcome.css',
  'tinymce/*'
]
