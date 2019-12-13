module.exports = {
  title: 'AlchemyCMS Guides',
  description: 'Developer Guidelines for AlchemyCMS',
  head: [
    [
      'link', {
        rel: 'stylesheet',
        href: 'https://fonts.googleapis.com/css?family=Open+Sans:400,400i,700,700i|Source+Sans+Pro:900'
      }
    ]
  ],
  plugins: [
    ['@vuepress/google-analytics', {
      ga: 'UA-22277258-1'
    }]
  ],
  themeConfig: {
    repo: 'AlchemyCMS/alchemy-guides',
    editLinks: true,
    docsDir: 'guides',
    home: true,
    lastUpdated: 'Last Updated',
    smoothScroll: true,
    nav: [
      {
        text: "Getting Started",
        link: 'getting_started.html'
      },
      {
        text: 'Basics',
        items: [
          {
            text: "About AlchemyCMS",
            link: 'about'
          },
          {
            text: "Pages",
            link: 'pages'
          },
          {
            text: "Cells",
            link: 'cells'
          },
          {
            text: "Elements",
            link: 'elements'
          },
          {
            text: "Essences",
            link: 'essences'
          },
          {
            text: "Rendering images",
            link: 'render_images'
          },
          {
            text: "Configuration",
            link: 'configuration'
          },
          {
            text: "Upgrading",
            link: 'upgrading'
          }
        ]
      },
      {
        text: "Guides",
        items: [
          {
            text: "How to create a blog template",
            link: 'best_practice_create_blog_template'
          },
          {
            text: "How to create a contact form",
            link: 'best_practice_create_form'
          },
          {
            text: "Customize the Richtext Editor",
            link: 'customize_tinymce'
          },
          {
            text: "Create custom essences",
            link: 'create_essences'
          },
          {
            text: "Deploy to Heroku",
            link: 'deploy_on_heroku'
          },
          {
            text: "Deploy to RailsHoster",
            link: 'deploy_on_railshoster'
          },
          {
            text: "Create custom modules",
            link: 'create_modules'
          },
          {
            text: "Create a custom authentication",
            link: 'custom_authentication'
          },
          {
            text: "Extending Alchemy",
            link: 'extending_alchemy'
          }
        ]
      }
    ],
    sidebar: 'auto',
    algolia: {
      apiKey: '5f50a085ecc6f17f5ba1bc8911c3cc90',
      indexName: 'alchemy-cms'
    }
  }
};
