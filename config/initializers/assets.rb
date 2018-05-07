# Add Alchemy assets for precompiling
Rails.application.config.assets.precompile += [
  'alchemy/admin/all.css',
  'alchemy/admin/all.js',
  'alchemy/alchemy-logo.svg',
  'alchemy/favicon.ico',
  'alchemy/preview.js',
  'alchemy/menubar.css',
  'alchemy/menubar.js',
  'alchemy/print.css',
  'alchemy/welcome.css',
  'Jcrop.gif',
  'tinymce/*'
]
