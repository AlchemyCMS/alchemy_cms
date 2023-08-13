import { defaultTheme } from "@vuepress/theme-default"
import { docsearchPlugin } from "@vuepress/plugin-docsearch"
import { shikiPlugin } from "@vuepress/plugin-shiki"

const VERSIONS = [4, 5, 6, 7]
const CURRENT_VERSION = process.env.VERSION || 7
const VERSION_NAVITEMS = {
  4: [
    {
      text: "Getting Started",
      link: "getting_started",
    },
    {
      text: "Basics",
      children: [
        {
          text: "About AlchemyCMS",
          link: "about",
        },
        {
          text: "Pages",
          link: "pages",
        },
        {
          text: "Cells",
          link: "cells",
        },
        {
          text: "Elements",
          link: "elements",
        },
        {
          text: "Essences",
          link: "essences",
        },
        {
          text: "Rendering images",
          link: "render_images",
        },
        {
          text: "Configuration",
          link: "configuration",
        },
        {
          text: "Upgrading",
          link: "upgrading",
        },
      ],
    },
    {
      text: "How To",
      children: [
        {
          text: "Create a blog template",
          link: "best_practice_create_blog_template",
        },
        {
          text: "Create a contact form",
          link: "best_practice_create_form",
        },
        {
          text: "Customize the Richtext Editor",
          link: "customize_tinymce",
        },
        {
          text: "Create custom essences",
          link: "create_essences",
        },
        {
          text: "Deploy to Heroku",
          link: "deploy_on_heroku",
        },
        {
          text: "Create custom modules",
          link: "create_modules",
        },
        {
          text: "Create a custom authentication",
          link: "custom_authentication",
        },
        {
          text: "Extend Alchemy",
          link: "extending_alchemy",
        },
      ],
    },
  ],
  5: [
    {
      text: "Getting Started",
      link: "getting_started",
    },
    {
      text: "Basics",
      children: [
        {
          text: "About AlchemyCMS",
          link: "about",
        },
        {
          text: "Pages",
          link: "pages",
        },
        {
          text: "Elements",
          link: "elements",
        },
        {
          text: "Essences",
          link: "essences",
        },
        {
          text: "Rendering images",
          link: "render_images",
        },
        {
          text: "Configuration",
          link: "configuration",
        },
        {
          text: "Upgrading",
          link: "upgrading",
        },
      ],
    },
    {
      text: "How To",
      children: [
        {
          text: "Create a blog template",
          link: "best_practice_create_blog_template",
        },
        {
          text: "Create a contact form",
          link: "best_practice_create_form",
        },
        {
          text: "Customize the Richtext Editor",
          link: "customize_tinymce",
        },
        {
          text: "Create custom essences",
          link: "create_essences",
        },
        {
          text: "Deploy to Heroku",
          link: "deploy_on_heroku",
        },
        {
          text: "Create custom modules",
          link: "create_modules",
        },
        {
          text: "Create a custom authentication",
          link: "custom_authentication",
        },
        {
          text: "Extend Alchemy",
          link: "extending_alchemy",
        },
      ],
    },
  ],
  6: [
    {
      text: "Getting Started",
      link: "getting_started",
    },
    {
      text: "Basics",
      children: [
        {
          text: "About AlchemyCMS",
          link: "about",
        },
        {
          text: "Pages",
          link: "pages",
        },
        {
          text: "Elements",
          link: "elements",
        },
        {
          text: "Ingredients",
          link: "ingredients",
        },
        {
          text: "Rendering images",
          link: "render_images",
        },
        {
          text: "Configuration",
          link: "configuration",
        },
        {
          text: "Updating",
          link: "upgrading",
        },
      ],
    },
    {
      text: "How To",
      children: [
        {
          text: "Create a blog template",
          link: "how_to_create_a_blog_template",
        },
        {
          text: "Create a contact form",
          link: "how_to_create_a_contact_form",
        },
        {
          text: "Customize the Richtext Editor",
          link: "how_to_customize_tinymce",
        },
        {
          text: "Create custom ingredients",
          link: "how_to_create_custom_ingredients",
        },
        {
          text: "Deploy on Heroku",
          link: "how_to_deploy_on_heroku",
        },
        {
          text: "Create custom modules",
          link: "how_to_create_modules",
        },
        {
          text: "Add custom authentication",
          link: "how_to_add_custom_authentication",
        },
        {
          text: "Extend Alchemy",
          link: "how_to_extend_alchemy",
        },
      ],
    },
  ],
  7: [
    {
      text: "Getting Started",
      link: "getting_started",
    },
    {
      text: "Basics",
      children: [
        {
          text: "About AlchemyCMS",
          link: "about",
        },
        {
          text: "Pages",
          link: "pages",
        },
        {
          text: "Elements",
          link: "elements",
        },
        {
          text: "Ingredients",
          link: "ingredients",
        },
        {
          text: "Rendering images",
          link: "render_images",
        },
        {
          text: "Configuration",
          link: "configuration",
        },
        {
          text: "Updating",
          link: "upgrading",
        },
      ],
    },
    {
      text: "How To",
      children: [
        {
          text: "Create a blog template",
          link: "how_to_create_a_blog_template",
        },
        {
          text: "Create a contact form",
          link: "how_to_create_a_contact_form",
        },
        {
          text: "Customize the Richtext Editor",
          link: "how_to_customize_tinymce",
        },
        {
          text: "Create custom ingredients",
          link: "how_to_create_custom_ingredients",
        },
        {
          text: "Deploy on Heroku",
          link: "how_to_deploy_on_heroku",
        },
        {
          text: "Create custom modules",
          link: "how_to_create_modules",
        },
        {
          text: "Add custom authentication",
          link: "how_to_add_custom_authentication",
        },
        {
          text: "Extend Alchemy",
          link: "how_to_extend_alchemy",
        },
      ],
    },
  ],
}

const VERSION_NAVIGATION = {
  text: "Version",
  children: VERSIONS.map((version) => {
    return {
      text: `v${version}.x`,
      link: version === CURRENT_VERSION ? "/" : `/v${version}/`,
    }
  }),
}

export default {
  title: "AlchemyCMS",
  description:
    "The Rails CMS framework that plugs nicely into your existing app.",
  head: [
    [
      "link",
      {
        rel: "stylesheet",
        href: "https://fonts.googleapis.com/css?family=Open+Sans:400,400i,700,700i|Source+Sans+Pro:900",
      },
    ],
  ],
  plugins: [
    docsearchPlugin({
      apiKey: "02e92bf5a88addf72d649f29ef77243a",
      appId: "SJXVVCKUQL",
      indexName: "alchemy-cms",
    }),
    shikiPlugin({
      langs: [
        "html",
        "css",
        "diff",
        "javascript",
        "ruby",
        "erb",
        "bash",
        "yaml",
      ],
      theme: "one-dark-pro",
    }),
  ],
  theme: defaultTheme({
    repo: "AlchemyCMS/alchemy-guides",
    logo: "icon.svg",
    docsDir: "guides",
    navbar: [VERSION_NAVIGATION, ...VERSION_NAVITEMS[CURRENT_VERSION]],
    sidebar: "auto",
  }),
}
