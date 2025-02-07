import { defineConfig } from "vitepress"

const VERSIONS = [4, 5, 6, 7]
const CURRENT_VERSION = process.env.VERSION || 7
const VERSION_NAVITEMS = {
  4: [
    {
      text: "Getting Started",
      link: "/v4/getting_started",
    },
    {
      text: "Basics",
      collapsed: false,
      items: [
        {
          text: "About AlchemyCMS",
          link: "/v4/about",
        },
        {
          text: "Pages",
          link: "/v4/pages",
        },
        {
          text: "Cells",
          link: "/v4/cells",
        },
        {
          text: "Elements",
          link: "/v4/elements",
        },
        {
          text: "Essences",
          link: "/v4/essences",
        },
        {
          text: "Rendering images",
          link: "/v4/render_images",
        },
        {
          text: "Configuration",
          link: "/v4/configuration",
        },
        {
          text: "Upgrading",
          link: "/v4/upgrading",
        },
      ],
    },
    {
      text: "How To",
      collapsed: false,
      items: [
        {
          text: "Create a blog template",
          link: "/v4/best_practice_create_blog_template",
        },
        {
          text: "Create a contact form",
          link: "/v4/best_practice_create_form",
        },
        {
          text: "Customize the Richtext Editor",
          link: "/v4/customize_tinymce",
        },
        {
          text: "Create custom essences",
          link: "/v4/create_essences",
        },
        {
          text: "Deploy to Heroku",
          link: "/v4/deploy_on_heroku",
        },
        {
          text: "Create custom modules",
          link: "/v4/create_modules",
        },
        {
          text: "Create a custom authentication",
          link: "/v4/custom_authentication",
        },
        {
          text: "Extend Alchemy",
          link: "/v4/extending_alchemy",
        },
      ],
    },
  ],
  5: [
    {
      text: "Getting Started",
      link: "/v5/getting_started",
    },
    {
      text: "Basics",
      collapsed: false,
      items: [
        {
          text: "About AlchemyCMS",
          link: "/v5/about",
        },
        {
          text: "Pages",
          link: "/v5/pages",
        },
        {
          text: "Elements",
          link: "/v5/elements",
        },
        {
          text: "Essences",
          link: "/v5/essences",
        },
        {
          text: "Rendering images",
          link: "/v5/render_images",
        },
        {
          text: "Configuration",
          link: "/v5/configuration",
        },
        {
          text: "Upgrading",
          link: "/v5/upgrading",
        },
      ],
    },
    {
      text: "How To",
      collapsed: false,
      items: [
        {
          text: "Create a blog template",
          link: "/v5/best_practice_create_blog_template",
        },
        {
          text: "Create a contact form",
          link: "/v5/best_practice_create_form",
        },
        {
          text: "Customize the Richtext Editor",
          link: "/v5/customize_tinymce",
        },
        {
          text: "Create custom essences",
          link: "/v5/create_essences",
        },
        {
          text: "Deploy to Heroku",
          link: "/v5/deploy_on_heroku",
        },
        {
          text: "Create custom modules",
          link: "/v5/create_modules",
        },
        {
          text: "Create a custom authentication",
          link: "/v5/custom_authentication",
        },
        {
          text: "Extend Alchemy",
          link: "/v5/extending_alchemy",
        },
      ],
    },
  ],
  6: [
    {
      text: "Getting Started",
      link: "/v6/getting_started",
    },
    {
      text: "Basics",
      collapsed: false,
      items: [
        {
          text: "About AlchemyCMS",
          link: "/v6/about",
        },
        {
          text: "Pages",
          link: "/v6/pages",
        },
        {
          text: "Elements",
          link: "/v6/elements",
        },
        {
          text: "Ingredients",
          link: "/v6/ingredients",
        },
        {
          text: "Rendering images",
          link: "/v6/render_images",
        },
        {
          text: "Configuration",
          link: "/v6/configuration",
        },
        {
          text: "Updating",
          link: "/v6/upgrading",
        },
      ],
    },
    {
      text: "How To",
      collapsed: false,
      items: [
        {
          text: "Create a blog template",
          link: "/v6/how_to_create_a_blog_template",
        },
        {
          text: "Create a contact form",
          link: "/v6/how_to_create_a_contact_form",
        },
        {
          text: "Customize the Richtext Editor",
          link: "/v6/how_to_customize_tinymce",
        },
        {
          text: "Create custom ingredients",
          link: "/v6/how_to_create_custom_ingredients",
        },
        {
          text: "Deploy on Heroku",
          link: "/v6/how_to_deploy_on_heroku",
        },
        {
          text: "Create custom modules",
          link: "/v6/how_to_create_modules",
        },
        {
          text: "Add custom authentication",
          link: "/v6/how_to_add_custom_authentication",
        },
        {
          text: "Extend Alchemy",
          link: "/v6/how_to_extend_alchemy",
        },
      ],
    },
  ],
  7: [
    {
      text: "Getting Started",
      link: "/getting_started",
    },
    {
      text: "Basics",
      collapsed: false,
      items: [
        {
          text: "About AlchemyCMS",
          link: "/about",
        },
        {
          text: "Pages",
          link: "/pages",
        },
        {
          text: "Elements",
          link: "/elements",
        },
        {
          text: "Ingredients",
          link: "/ingredients",
        },
        {
          text: "Rendering images",
          link: "/render_images",
        },
        {
          text: "Configuration",
          link: "/configuration",
        },
        {
          text: "Updating",
          link: "/upgrading",
        },
      ],
    },
    {
      text: "How To",
      collapsed: false,
      items: [
        {
          text: "Create a blog template",
          link: "/how_to_create_a_blog_template",
        },
        {
          text: "Create a contact form",
          link: "/how_to_create_a_contact_form",
        },
        {
          text: "Customize the Richtext Editor",
          link: "/how_to_customize_tinymce",
        },
        {
          text: "Create custom ingredients",
          link: "/how_to_create_custom_ingredients",
        },
        {
          text: "Deploy on Heroku",
          link: "/how_to_deploy_on_heroku",
        },
        {
          text: "Create custom modules",
          link: "/how_to_create_modules",
        },
        {
          text: "Add custom authentication",
          link: "/how_to_add_custom_authentication",
        },
        {
          text: "Extend Alchemy",
          link: "/how_to_extend_alchemy",
        },
      ],
    },
  ],
}

const navItems = VERSIONS.map((version) => {
  const currentVersion = version === CURRENT_VERSION
  return {
    text: currentVersion ? `v${version} (latest)` : `v${version}`,
    link: currentVersion ? "/" : `/v${version}`,
    activeMatch: currentVersion ? `^\/(?!(v\d+))` : `/v${version}/`,
  }
})

const sidebar = VERSIONS.reduce((obj, version) => {
  const folder = version === CURRENT_VERSION ? "" : `v${version}/`
  return {
    ...obj,
    [`/${folder}`]: VERSION_NAVITEMS[version],
  }
}, {})

// https://vitepress.dev/reference/site-config
export default defineConfig({
  title: "AlchemyCMS",
  head: [
    ['link', { rel: 'icon', type: 'image/x-icon', href: '/favicon.ico' }],
  ],
  description:
    "Alchemy is the Open Source Rails CMS framework for the component based web that can be used as classic server side rendered or headless CMS.",
  // https://vitepress.dev/reference/default-theme-config
  themeConfig: {
    logo: "/icon.svg",
    nav: [
      {
        text: "Version",
        items: navItems,
      },
    ],
    socialLinks: [
      { icon: "github", link: "https://github.com/AlchemyCMS/alchemy_cms" },
      { icon: "mastodon", link: "https://ruby.social/@alchemy_cms" },
    ],
    sidebar,
    editLink: {
      pattern:
        "https://github.com/AlchemyCMS/alchemy-guides/edit/main/guides/:path",
    },
    footer: {
      message: `
      BSD-3 Licensed &middot; Hosting sponsored by <a href="https://www.netlify.com" target="_blank">netlify</a>`,
      copyright:
        'Copyright © 2010 - present <a href="https://blish.cloud" target="_blank">Blish GmbH</a>',
    },
    search: {
      provider: "algolia",
      options: {
        apiKey: "02e92bf5a88addf72d649f29ef77243a",
        appId: "SJXVVCKUQL",
        indexName: "alchemy-cms",
      },
    },
  },
  lastUpdated: true,
  ignoreDeadLinks: "localhostLinks",
})
