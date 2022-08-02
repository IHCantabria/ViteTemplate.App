# Template setup

## Template cloning

Use [Degit](https://github.com/Rich-Harris/degit) to copy the app template locally.

Degit makes a copy of a git repository without downloading the entire git history.

```
npx degit IHCantabria/ViteTemplate.App local-repo-name
```

## Template setup

Install project dependencies locally

```
npm install
```

Additionally, you might want to install:

- [bulma](https://github.com/jgthms/bulma)
- [vuex](https://github.com/vuejs/vuex/tree/4.0)
- [vue-router](https://github.com/vuejs/vue-router-next)

## Additional setup

- Folder named "certificate" with local certificates for https local server
- Make sure you are using a compatible Node.js version (Node.js 14.18+ / 16+)

# Project README

# Project Title

> Project Title
> Project description [Project Name](project url)

## Project setup

```
npm install
```

### Compiles and hot-reloads for development

```
npm run dev
```

### Compiles and minifies for production

```
npm run build
```

### Preview production version locally

```
npm run serve
```

### Deploy version (patch/minor/major)

```
npm run deploy-patch
```

### Push to remote repo (master + tags)

```
npm run postversion
```

### Analyze code with linter tools, autofix if it's available

```
npm run lint
```

### Check if the linter rules are compatible

```
npm run stylelint-check
```

### Launch test ui tool

```
npm run test
```

### Launch coverage code tool

```
npm run coverage
```

## Built With

- [Vue](https://vuejs.org/) - The progressive javascript framework
- [Vite](https://vitejs.dev/) - Frontend Tooling
- [Rollup](https://www.rollupjs.org/guide/en/) - Bundling

## Credits

[IH Cantabria](https://github.com/IHCantabria)

## License

This software uses:

- [Bulma](https://bulma.io/) - MIT License
- [Leaflet](https://leafletjs.com/) - Branded License
- [Thredds Data Server](https://www.unidata.ucar.edu/software/tds/current/) - BSD-3 license

  <a href="https://www.unidata.ucar.edu/software/tds/" title="THREDDS Data Server"><img src="https://unidata.ucar.edu/images/logos/badges/badge_tds_100.jpg" width="100px"></a>

### Customize configuration

See [Configuration Reference](https://vitejs.dev/config/).
