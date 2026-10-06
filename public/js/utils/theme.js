/* ============================================
   THEME - Dark/Light Mode Management
   ============================================ */

import { storage } from './storage.js';

class ThemeManager {
  constructor() {
    this.currentTheme = 'light';
    this.toggleBtn = null;
    this.moonIcon = null;
    this.sunIcon = null;
  }
  
  /**
   * Initialize theme manager
   */
  init() {
    // Get saved theme or system preference
    const savedTheme = storage.getTheme();
    const systemPreference = window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
    const initialTheme = savedTheme || systemPreference;
    
    // Get UI elements
    this.toggleBtn = document.getElementById('theme-toggle');
    this.moonIcon = this.toggleBtn?.querySelector('.moon-icon');
    this.sunIcon = this.toggleBtn?.querySelector('.sun-icon');
    
    // Set initial theme
    this.setTheme(initialTheme);
    
    // Add event listener
    if (this.toggleBtn) {
      this.toggleBtn.addEventListener('click', () => this.toggle());
    }
    
    // Listen for system theme changes
    window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', (e) => {
      if (!storage.getTheme()) {
        // Only auto-switch if user hasn't manually set a theme
        this.setTheme(e.matches ? 'dark' : 'light');
      }
    });
  }
  
  /**
   * Set theme
   * @param {string} theme - Theme name ('light' or 'dark')
   */
  setTheme(theme) {
    this.currentTheme = theme;
    document.documentElement.setAttribute('data-theme', theme);
    storage.setTheme(theme);
    this.updateIcon();
  }
  
  /**
   * Toggle between light and dark theme
   */
  toggle() {
    const newTheme = this.currentTheme === 'light' ? 'dark' : 'light';
    this.setTheme(newTheme);
  }
  
  /**
   * Update icon based on current theme
   */
  updateIcon() {
    if (!this.moonIcon || !this.sunIcon) return;
    
    if (this.currentTheme === 'dark') {
      this.moonIcon.style.display = 'none';
      this.sunIcon.style.display = 'block';
    } else {
      this.moonIcon.style.display = 'block';
      this.sunIcon.style.display = 'none';
    }
  }
  
  /**
   * Get current theme
   * @returns {string} Current theme name
   */
  getTheme() {
    return this.currentTheme;
  }
  
  /**
   * Check if dark mode is active
   * @returns {boolean} True if dark mode
   */
  isDark() {
    return this.currentTheme === 'dark';
  }
}

// Export singleton instance
export const themeManager = new ThemeManager();
