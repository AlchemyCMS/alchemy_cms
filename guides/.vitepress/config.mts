import { defineConfig } from "vitepress"
import llmstxtPlugin from "vitepress-plugin-llmstxt"
import { VERSIONS, CURRENT_VERSION, NEXT_VERSION, folderOf } from "./versions.js"
const VERSION_NAVITEMS = {
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
          text: "Rendering Images",
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
          text: "Create a Blog",
          link: "/v6/how_to_create_a_blog_template",
        },
        {
          text: "Create a Contact Form",
          link: "/v6/how_to_create_a_contact_form",
        },
        {
          text: "Customize the Richtext Editor",
          link: "/v6/how_to_customize_tinymce",
        },
        {
          text: "Create Custom Ingredients",
          link: "/v6/how_to_create_custom_ingredients",
        },
        {
          text: "Deploy on Heroku",
          link: "/v6/how_to_deploy_on_heroku",
        },
        {
          text: "Create Custom Modules",
          link: "/v6/how_to_create_modules",
        },
        {
          text: "Add Custom Authentication",
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
      link: "/v7/getting_started",
    },
    {
      text: "Basics",
      collapsed: false,
      items: [
        {
          text: "About AlchemyCMS",
          link: "/v7/about",
        },
        {
          text: "Pages",
          link: "/v7/pages",
        },
        {
          text: "Elements",
          link: "/v7/elements",
        },
        {
          text: "Ingredients",
          link: "/v7/ingredients",
        },
        {
          text: "Rendering Images",
          link: "/v7/render_images",
        },
        {
          text: "Configuration",
          link: "/v7/configuration",
        },
        {
          text: "Updating",
          link: "/v7/upgrading",
        },
      ],
    },
    {
      text: "How To",
      collapsed: false,
      items: [
        {
          text: "Create a Blog",
          link: "/v7/how_to_create_a_blog_template",
        },
        {
          text: "Create a Contact Form",
          link: "/v7/how_to_create_a_contact_form",
        },
        {
          text: "Customize the Richtext Editor",
          link: "/v7/how_to_customize_tinymce",
        },
        {
          text: "Create Custom Ingredients",
          link: "/v7/how_to_create_custom_ingredients",
        },
        {
          text: "Deploy on Heroku",
          link: "/v7/how_to_deploy_on_heroku",
        },
        {
          text: "Create Custom Modules",
          link: "/v7/how_to_create_modules",
        },
        {
          text: "Add Custom Authentication",
          link: "/v7/how_to_add_custom_authentication",
        },
        {
          text: "Extend Alchemy",
          link: "/v7/how_to_extend_alchemy",
        },
      ],
    },
  ],
  8: [
    {
      text: "Introduction",
      collapsed: false,
      items: [
        {
          text: "About AlchemyCMS",
          link: "/about",
        },
        {
          text: "Getting Started",
          link: "/getting_started",
        },
      ],
    },
    {
      text: "Basics",
      collapsed: false,
      items: [
        {
          text: "Elements",
          link: "/elements",
        },
        {
          text: "Ingredients",
          link: "/ingredients",
        },
        {
          text: "Pages",
          link: "/pages",
        },
        {
          text: "Menus",
          link: "/menus",
        },
        {
          text: "Rendering Images",
          link: "/render_images",
        },
        {
          text: "Configuration",
          link: "/configuration",
        },
        {
          text: "I18n",
          link: "/i18n",
        },
        {
          text: "Seeder",
          link: "/seeder",
        },
        {
          text: "Deployment",
          link: "/deployment",
        },
        {
          text: "Updating",
          link: "/upgrading",
        },
      ],
    },
    {
      text: "Admin Modules",
      collapsed: true,
      items: [
        {
          text: "Library",
          link: "/library",
        },
        {
          text: "Tags",
          link: "/tags",
        },
        {
          text: "Languages",
          link: "/languages",
        },
        {
          text: "Sites",
          link: "/sites",
        },
        {
          text: "Custom Modules",
          link: "/how_to_create_modules",
        },
      ],
    },
    {
      text: "How To",
      collapsed: true,
      items: [
        {
          text: "Create a Blog",
          link: "/how_to_create_a_blog",
        },
        {
          text: "Create a Contact Form",
          link: "/how_to_create_a_contact_form",
        },
        {
          text: "Customize the Richtext Editor",
          link: "/how_to_customize_tinymce",
        },
        {
          text: "Create Custom Ingredients",
          link: "/how_to_create_custom_ingredients",
        },
        {
          text: "Deploy with Kamal",
          link: "/how_to_deploy_with_kamal",
        },
        {
          text: "Add Custom Authentication",
          link: "/how_to_add_custom_authentication",
        },
        {
          text: "Integrate Into Existing Rails App",
          link: "/how_to_integrate_into_existing_rails_app",
        },
        {
          text: "Extend Alchemy",
          link: "/how_to_extend_alchemy",
        },
      ],
    },
  ],
  9: [
    {
      text: "Introduction",
      collapsed: false,
      items: [
        {
          text: "About AlchemyCMS",
          link: "/next/about",
        },
        {
          text: "Getting Started",
          link: "/next/getting_started",
        },
      ],
    },
    {
      text: "Basics",
      collapsed: false,
      items: [
        {
          text: "Elements",
          link: "/next/elements",
        },
        {
          text: "Ingredients",
          link: "/next/ingredients",
        },
        {
          text: "Pages",
          link: "/next/pages",
        },
        {
          text: "Menus",
          link: "/next/menus",
        },
        {
          text: "Rendering Images",
          link: "/next/render_images",
        },
        {
          text: "Configuration",
          link: "/next/configuration",
        },
        {
          text: "I18n",
          link: "/next/i18n",
        },
        {
          text: "Seeder",
          link: "/next/seeder",
        },
        {
          text: "Deployment",
          link: "/next/deployment",
        },
        {
          text: "Updating",
          link: "/next/upgrading",
        },
      ],
    },
    {
      text: "Admin Modules",
      collapsed: true,
      items: [
        {
          text: "Library",
          link: "/next/library",
        },
        {
          text: "Tags",
          link: "/next/tags",
        },
        {
          text: "Languages",
          link: "/next/languages",
        },
        {
          text: "Sites",
          link: "/next/sites",
        },
        {
          text: "Custom Modules",
          link: "/next/how_to_create_modules",
        },
      ],
    },
    {
      text: "How To",
      collapsed: true,
      items: [
        {
          text: "Create a Blog",
          link: "/next/how_to_create_a_blog",
        },
        {
          text: "Create a Contact Form",
          link: "/next/how_to_create_a_contact_form",
        },
        {
          text: "Customize the Richtext Editor",
          link: "/next/how_to_customize_tinymce",
        },
        {
          text: "Create Custom Ingredients",
          link: "/next/how_to_create_custom_ingredients",
        },
        {
          text: "Deploy with Kamal",
          link: "/next/how_to_deploy_with_kamal",
        },
        {
          text: "Add Custom Authentication",
          link: "/next/how_to_add_custom_authentication",
        },
        {
          text: "Integrate Into Existing Rails App",
          link: "/next/how_to_integrate_into_existing_rails_app",
        },
        {
          text: "Extend Alchemy",
          link: "/next/how_to_extend_alchemy",
        },
      ],
    },
  ],
}

const VERSION_LABELS = {
  [CURRENT_VERSION]: "latest",
  [NEXT_VERSION]: "next",
}

const navItems = VERSIONS.map((version) => {
  const folder = folderOf(version)
  const label = VERSION_LABELS[version]
  return {
    text: label ? `v${version} (${label})` : `v${version}`,
    link: folder ? `/${folder}` : "/",
    activeMatch: folder ? `/${folder}/` : `^\/(?!(v\d+|next))`,
  }
})

const sidebar = VERSIONS.reduce((obj, version) => {
  const folder = folderOf(version)
  return {
    ...obj,
    [folder ? `/${folder}/` : "/"]: VERSION_NAVITEMS[version],
  }
}, {})

// https://vitepress.dev/reference/site-config
export default defineConfig({
  title: "AlchemyCMS",
  srcExclude: ["README.md"],
  head: [
    ["link", { rel: "icon", type: "image/x-icon", href: "/favicon.ico" }],
    [
      "script",
      {
        async: "",
        src: "https://analytics.blish.cloud/js/pa-CubCE1Mo6pmiWreeps0Sd.js",
      },
    ],
    [
      "script",
      {},
      `window.plausible=window.plausible||function(){(plausible.q=plausible.q||[]).push(arguments)},plausible.init=plausible.init||function(i){plausible.o=i||{}};
      plausible.init()`,
    ],
  ],
  description:
    "Alchemy is the Open Source Rails CMS framework for the component based web that can be used as classic server side rendered or headless CMS.",
  // https://vitepress.dev/reference/default-theme-config
  themeConfig: {
    logo: "/icon.svg",
    nav: [
      {
        text: "Home",
        link: "https://www.alchemy-cms.com",
      },
      {
        text: "Extensions",
        link: "/extensions",
      },
      {
        text: "Version",
        items: navItems,
      },
    ],
    socialLinks: [
      { icon: "github", link: "https://github.com/AlchemyCMS/" },
      { icon: "mastodon", link: "https://ruby.social/@alchemy_cms" },
      { icon: "bluesky", link: "https://bsky.app/profile/alchemy-cms.com" },
      { icon: "slack", link: "https://alchemy-cms.slack.com" },
    ],
    sidebar,
    editLink: {
      pattern:
        "https://github.com/AlchemyCMS/alchemy_cms/edit/main/guides/:path",
    },
    footer: {
      message: `
      BSD-3 Licensed &middot; Hosting sponsored by <a href="https://www.netlify.com" target="_blank">netlify</a>`,
      copyright:
        'Copyright © 2010 - present <a href="https://blish.cloud" target="_blank">Blish GmbH</a>',
    },
    search: {
      provider: "local",
      options: {
        _render(src, env, md) {
          const html = md.render(src, env)
          if (/^(v\d+|next)\//.test(env.relativePath)) return ""
          return html
        },
      },
    },
  },
  lastUpdated: true,
  ignoreDeadLinks: "localhostLinks",
  vite: {
    plugins: [llmstxtPlugin({ ignore: ["README.md"] })],
  },
})
