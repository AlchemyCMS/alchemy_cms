# The AlchemyCMS Guides

The guides are created with [VuePress](https://v2.vuepress.vuejs.org) and are written in [Markdown](https://daringfireball.net/projects/markdown/syntax).

[![Deploys by Netlify](https://www.netlify.com/img/global/badges/netlify-color-bg.svg)](https://www.netlify.com)

## File locations

The actual guides sourcefiles live in the `/guides` folder.

## Preview the guides

Run

```bash
yarn install
```

to install [VuePress](https://v2.vuepress.vuejs.org).

To run a local preview server, run

```bash
yarn guides:preview
```

The server will be available at [http://localhost:8080](http://localhost:8080).

## Building

Build the guides html files with:

```bash
yarn guides:build
```

## Deployment

Deployment is done automatically via [netlify](https://www.netlify.com) whenever a change is merged into the master branch.

## Contributing

1. Fork it
2. Create a branch (`git checkout -b my-new-guide`)
3. Commit your changes (`git commit -am 'Add new guide for elements'`)
4. Push to the branch (`git push origin my-new-guide`)
5. Create new Pull Request
