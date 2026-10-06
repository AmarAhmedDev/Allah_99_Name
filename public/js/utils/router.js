/* ============================================
   ROUTER - Simple SPA Router
   ============================================ */

class Router {
  constructor() {
    this.routes = {};
    this.currentRoute = null;
    this.currentParams = {};
    
    // Listen for hash changes
    window.addEventListener('hashchange', () => this.handleRoute());
    window.addEventListener('load', () => this.handleRoute());
  }
  
  /**
   * Register a route
   * @param {string} path - Route path (e.g., '/home', '/detail/:id')
   * @param {Function} handler - Function to call when route matches
   */
  register(path, handler) {
    this.routes[path] = handler;
  }
  
  /**
   * Navigate to a route
   * @param {string} path - Path to navigate to
   */
  navigate(path) {
    window.location.hash = path;
  }
  
  /**
   * Go back in history
   */
  back() {
    window.history.back();
  }
  
  /**
   * Handle route change
   */
  async handleRoute() {
    const hash = window.location.hash.slice(1) || '/';
    const { route, params } = this.matchRoute(hash);
    
    if (route) {
      this.currentRoute = route;
      this.currentParams = params;
      
      // Hide loading screen if still visible
      const loadingScreen = document.getElementById('loading-screen');
      if (loadingScreen) {
        loadingScreen.style.display = 'none';
      }
      
      // Show main content
      const mainContent = document.getElementById('main-content');
      if (mainContent) {
        mainContent.style.display = 'flex';
      }
      
      // Call the route handler
      await this.routes[route](params);
      
      // Scroll to top
      window.scrollTo({ top: 0, behavior: 'smooth' });
    } else {
      // No route found, redirect to home
      this.navigate('/');
    }
  }
  
  /**
   * Match current hash to registered routes
   * @param {string} hash - Current hash
   * @returns {Object} Matched route and parameters
   */
  matchRoute(hash) {
    // Try exact match first
    if (this.routes[hash]) {
      return { route: hash, params: {} };
    }
    
    // Try pattern matching for dynamic routes
    for (const route in this.routes) {
      const pattern = this.createRoutePattern(route);
      const match = hash.match(pattern);
      
      if (match) {
        const params = this.extractParams(route, match);
        return { route, params };
      }
    }
    
    return { route: null, params: {} };
  }
  
  /**
   * Create regex pattern for route matching
   * @param {string} route - Route path
   * @returns {RegExp} Regex pattern
   */
  createRoutePattern(route) {
    const pattern = route
      .replace(/\//g, '\\/')
      .replace(/:(\w+)/g, '([^/]+)');
    return new RegExp(`^${pattern}$`);
  }
  
  /**
   * Extract parameters from matched route
   * @param {string} route - Route path
   * @param {Array} match - Regex match array
   * @returns {Object} Extracted parameters
   */
  extractParams(route, match) {
    const params = {};
    const paramNames = route.match(/:(\w+)/g);
    
    if (paramNames) {
      paramNames.forEach((paramName, index) => {
        const cleanName = paramName.slice(1); // Remove ':'
        params[cleanName] = match[index + 1];
      });
    }
    
    return params;
  }
  
  /**
   * Get current route parameters
   * @returns {Object} Current parameters
   */
  getParams() {
    return this.currentParams;
  }
  
  /**
   * Get current route path
   * @returns {string} Current route
   */
  getCurrentRoute() {
    return this.currentRoute;
  }
}

// Export singleton instance
export const router = new Router();
