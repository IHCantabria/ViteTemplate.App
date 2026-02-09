# URL Routing Configuration

## Overview

This application uses Vue Router with **HTML5 History Mode** (`createWebHistory()`), which provides clean URLs without hash fragments. This mode requires specific server-side configuration to handle client-side routing properly.

## History Mode Explained

### HTML5 Mode vs Hash Mode

The application uses **HTML5 History Mode**, which produces URLs like:
```
https://example.com/1
https://example.com/2
https://example.com/3
```

This differs from **Hash Mode**, which would produce URLs like:
```
https://example.com/#/1
https://example.com/#/2
```

### Why Server Configuration is Required

In a Single Page Application (SPA), the client handles routing. When a user navigates within the app, Vue Router updates the URL without making server requests. However, problems arise when:

1. **Direct URL Access**: A user enters `https://example.com/1` directly in the browser
2. **Page Refresh**: A user refreshes the page while on a specific route
3. **Bookmarked Links**: A user accesses a bookmarked deep link

In these cases, the browser makes a request to the server for `/1`. Without proper configuration, the server looks for a physical file at that path and returns a **404 error** because the file doesn't exist.

**Solution**: Configure the server to serve `index.html` for all routes that don't match static assets, allowing Vue Router to handle the routing client-side.

## Current Server Configuration

### Internet Information Services (IIS)

This application is currently deployed on **Microsoft IIS** servers at IHCantabria.

#### Prerequisites

- **IIS URL Rewrite Module** must be installed
- Download: [https://www.iis.net/downloads/microsoft/url-rewrite](https://www.iis.net/downloads/microsoft/url-rewrite)

#### Configuration Files

The project includes environment-specific `web.config` files located in `/server-config/`:

- `web.config.development`
- `web.config.production`

#### Configuration Explanation

The `web.config` file contains a URL rewrite rule that:

```xml
<rule name="Handle History Mode and custom 404/500" stopProcessing="true">
  <match url="(.*)" />
  <conditions logicalGrouping="MatchAll">
    <add input="{REQUEST_FILENAME}" matchType="IsFile" negate="true" />
    <add input="{REQUEST_FILENAME}" matchType="IsDirectory" negate="true" />
  </conditions>
  <action type="Rewrite" url="/" />
</rule>
```

**How it works**:
1. Matches all incoming URLs
2. Checks if the requested path corresponds to an actual file or directory
3. If NOT a file or directory, rewrites the request to serve `/index.html`
4. Allows Vue Router to parse the URL and render the appropriate component

## Alternative Server Configurations

If the application is migrated to a different infrastructure (Apache, Nginx, Node.js, Netlify, Vercel, etc.), refer to the official Vue Router documentation for server-specific configurations:

[Vue Router - Example Server Configurations](https://router.vuejs.org/guide/essentials/history-mode.html#Example-Server-Configurations)

## Important Considerations

### 404 Error Handling

With this configuration, the server will no longer return proper 404 HTTP status codes for non-existent routes. All unknown paths serve `index.html` with a 200 status.

**Client-Side Solution**: The application should implement a catch-all route in Vue Router to display a custom 404 page:

```javascript
const router = createRouter({
  history: createWebHistory(),
  routes: [
    // ... other routes
    { path: '/:pathMatch(.*)*', component: NotFoundComponent }
  ]
})
```

### Deployment Checklist

When deploying this application:

1. ✓ Ensure the appropriate `web.config` file is deployed to the server root
2. ✓ Verify IIS URL Rewrite module is installed
3. ✓ Test direct URL access to various routes
4. ✓ Test page refresh on different routes
5. ✓ Verify static assets (CSS, JS, images) load correctly

## References

- **Vue Router Official Documentation**: [https://router.vuejs.org/guide/essentials/history-mode.html](https://router.vuejs.org/guide/essentials/history-mode.html)
- **IIS URL Rewrite Module**: [https://www.iis.net/downloads/microsoft/url-rewrite](https://www.iis.net/downloads/microsoft/url-rewrite)
- **IIS URL Rewrite Documentation**: [https://docs.microsoft.com/en-us/iis/extensions/url-rewrite-module/](https://docs.microsoft.com/en-us/iis/extensions/url-rewrite-module/)

## Support

For questions or issues related to routing configuration, consult the Vue Router documentation or contact the development team.
