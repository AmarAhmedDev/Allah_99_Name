/* ============================================
   LOCAL STORAGE - Data Persistence
   ============================================ */

const STORAGE_KEYS = {
  THEME: 'asma_theme',
  MEMORIZED: 'asma_memorized',
  PROGRESS: 'asma_progress',
  RECENT: 'asma_recent',
  SETTINGS: 'asma_settings'
};

class Storage {
  /**
   * Get item from localStorage
   * @param {string} key - Storage key
   * @param {*} defaultValue - Default value if not found
   * @returns {*} Stored value or default
   */
  get(key, defaultValue = null) {
    try {
      const item = localStorage.getItem(key);
      return item ? JSON.parse(item) : defaultValue;
    } catch (error) {
      console.error('Error reading from localStorage:', error);
      return defaultValue;
    }
  }
  
  /**
   * Set item in localStorage
   * @param {string} key - Storage key
   * @param {*} value - Value to store
   */
  set(key, value) {
    try {
      localStorage.setItem(key, JSON.stringify(value));
      return true;
    } catch (error) {
      console.error('Error writing to localStorage:', error);
      return false;
    }
  }
  
  /**
   * Remove item from localStorage
   * @param {string} key - Storage key
   */
  remove(key) {
    try {
      localStorage.removeItem(key);
      return true;
    } catch (error) {
      console.error('Error removing from localStorage:', error);
      return false;
    }
  }
  
  /**
   * Clear all app data from localStorage
   */
  clearAll() {
    try {
      Object.values(STORAGE_KEYS).forEach(key => {
        localStorage.removeItem(key);
      });
      return true;
    } catch (error) {
      console.error('Error clearing localStorage:', error);
      return false;
    }
  }
  
  // Theme Management
  getTheme() {
    return this.get(STORAGE_KEYS.THEME, 'light');
  }
  
  setTheme(theme) {
    return this.set(STORAGE_KEYS.THEME, theme);
  }
  
  // Memorization Progress
  getMemorized() {
    return this.get(STORAGE_KEYS.MEMORIZED, []);
  }
  
  setMemorized(nameIds) {
    return this.set(STORAGE_KEYS.MEMORIZED, nameIds);
  }
  
  addMemorized(nameId) {
    const memorized = this.getMemorized();
    if (!memorized.includes(nameId)) {
      memorized.push(nameId);
      this.setMemorized(memorized);
    }
  }
  
  removeMemorized(nameId) {
    const memorized = this.getMemorized();
    const filtered = memorized.filter(id => id !== nameId);
    this.setMemorized(filtered);
  }
  
  isMemorized(nameId) {
    const memorized = this.getMemorized();
    return memorized.includes(nameId);
  }
  
  getMemorizedCount() {
    return this.getMemorized().length;
  }
  
  // Audio Progress
  getProgress() {
    return this.get(STORAGE_KEYS.PROGRESS, {
      currentIndex: 0,
      isPlaying: false
    });
  }
  
  setProgress(progress) {
    return this.set(STORAGE_KEYS.PROGRESS, progress);
  }
  
  // Recently Viewed
  getRecent() {
    return this.get(STORAGE_KEYS.RECENT, []);
  }
  
  addRecent(nameId) {
    const recent = this.getRecent();
    // Remove if already exists
    const filtered = recent.filter(id => id !== nameId);
    // Add to beginning
    filtered.unshift(nameId);
    // Keep only last 10
    const limited = filtered.slice(0, 10);
    this.set(STORAGE_KEYS.RECENT, limited);
  }
  
  // Settings
  getSettings() {
    return this.get(STORAGE_KEYS.SETTINGS, {
      autoPlay: true,
      volume: 1.0,
      showMeaning: true,
      showAmharic: true
    });
  }
  
  updateSettings(newSettings) {
    const current = this.getSettings();
    const updated = { ...current, ...newSettings };
    return this.set(STORAGE_KEYS.SETTINGS, updated);
  }
}

// Export singleton instance
export const storage = new Storage();
export { STORAGE_KEYS };
