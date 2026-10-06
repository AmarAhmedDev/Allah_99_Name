/* ============================================
   AUDIO PLAYER - Audio Management System
   ============================================ */

import { storage } from './utils/storage.js';

class AudioPlayer {
  constructor() {
    this.audio = null;
    this.currentIndex = 0;
    this.playlist = [];
    this.isPlaying = false;
    this.loop = false;
    this.autoPlay = true;
    this.listeners = {};
  }
  
  /**
   * Initialize audio player
   */
  init() {
    this.audio = document.getElementById('audio-player');
    if (!this.audio) {
      console.error('Audio element not found');
      return;
    }
    
    // Set up event listeners
    this.audio.addEventListener('ended', () => this.handleEnded());
    this.audio.addEventListener('play', () => this.handlePlay());
    this.audio.addEventListener('pause', () => this.handlePause());
    this.audio.addEventListener('error', (e) => this.handleError(e));
    this.audio.addEventListener('loadedmetadata', () => this.emit('loaded'));
    this.audio.addEventListener('timeupdate', () => this.emit('timeupdate'));
    
    // Load settings
    const settings = storage.getSettings();
    this.autoPlay = settings.autoPlay;
    this.audio.volume = settings.volume || 1.0;
  }
  
  /**
   * Set playlist
   * @param {Array} names - Array of name objects
   */
  setPlaylist(names) {
    this.playlist = names;
  }
  
  /**
   * Play audio by index
   * @param {number} index - Index in playlist
   */
  async playByIndex(index) {
    if (index < 0 || index >= this.playlist.length) {
      console.error('Invalid index');
      return;
    }
    
    this.currentIndex = index;
    const name = this.playlist[index];
    
    // For now, we'll use Text-to-Speech as placeholder
    // In production, replace with actual audio URLs from Firebase Storage
    await this.playName(name);
  }
  
  /**
   * Play a specific name
   * @param {Object} name - Name object
   */
  async playName(name) {
    try {
      // Emit loading event
      this.emit('loading', name);
      
      // Check if we have audio URL
      if (name.audio_url && name.audio_url !== '') {
        this.audio.src = name.audio_url;
        await this.audio.play();
      } else {
        // Use Web Speech API as fallback
        await this.speakText(name.arabic);
      }
      
      this.isPlaying = true;
      this.emit('play', name);
      
    } catch (error) {
      console.error('Error playing audio:', error);
      this.emit('error', error);
    }
  }
  
  /**
   * Use Web Speech API to speak Arabic text
   * @param {string} text - Arabic text to speak
   */
  async speakText(text) {
    return new Promise((resolve, reject) => {
      if (!('speechSynthesis' in window)) {
        reject(new Error('Speech synthesis not supported'));
        return;
      }
      
      // Cancel any ongoing speech
      window.speechSynthesis.cancel();
      
      const utterance = new SpeechSynthesisUtterance(text);
      utterance.lang = 'ar-SA'; // Arabic
      utterance.rate = 0.8; // Slower for learning
      utterance.pitch = 1.0;
      utterance.volume = 1.0;
      
      utterance.onend = () => {
        this.handleEnded();
        resolve();
      };
      
      utterance.onerror = (event) => {
        console.error('Speech synthesis error:', event);
        reject(event);
      };
      
      window.speechSynthesis.speak(utterance);
      this.isPlaying = true;
    });
  }
  
  /**
   * Play current track
   */
  async play() {
    if (this.playlist.length === 0) return;
    
    try {
      if (this.audio.src) {
        await this.audio.play();
      } else {
        await this.playByIndex(this.currentIndex);
      }
    } catch (error) {
      console.error('Play error:', error);
    }
  }
  
  /**
   * Pause playback
   */
  pause() {
    if (this.audio.src) {
      this.audio.pause();
    } else if ('speechSynthesis' in window) {
      window.speechSynthesis.pause();
    }
    this.isPlaying = false;
  }
  
  /**
   * Stop playback
   */
  stop() {
    this.pause();
    if (this.audio.src) {
      this.audio.currentTime = 0;
    }
    if ('speechSynthesis' in window) {
      window.speechSynthesis.cancel();
    }
    this.isPlaying = false;
    this.emit('stop');
  }
  
  /**
   * Play next track
   */
  async next() {
    let nextIndex = this.currentIndex + 1;
    
    if (nextIndex >= this.playlist.length) {
      if (this.loop) {
        nextIndex = 0;
      } else {
        this.stop();
        this.emit('playlistend');
        return;
      }
    }
    
    await this.playByIndex(nextIndex);
  }
  
  /**
   * Play previous track
   */
  async previous() {
    let prevIndex = this.currentIndex - 1;
    
    if (prevIndex < 0) {
      if (this.loop) {
        prevIndex = this.playlist.length - 1;
      } else {
        prevIndex = 0;
      }
    }
    
    await this.playByIndex(prevIndex);
  }
  
  /**
   * Toggle play/pause
   */
  async togglePlay() {
    if (this.isPlaying) {
      this.pause();
    } else {
      await this.play();
    }
  }
  
  /**
   * Set volume
   * @param {number} level - Volume level (0.0 to 1.0)
   */
  setVolume(level) {
    if (level < 0 || level > 1) return;
    this.audio.volume = level;
    storage.updateSettings({ volume: level });
  }
  
  /**
   * Get current name
   * @returns {Object} Current name object
   */
  getCurrentName() {
    return this.playlist[this.currentIndex] || null;
  }
  
  /**
   * Get current index
   * @returns {number} Current index
   */
  getCurrentIndex() {
    return this.currentIndex;
  }
  
  /**
   * Get total count
   * @returns {number} Total tracks
   */
  getTotalCount() {
    return this.playlist.length;
  }
  
  /**
   * Check if playing
   * @returns {boolean} Is playing
   */
  getIsPlaying() {
    return this.isPlaying;
  }
  
  /**
   * Handle audio ended
   */
  handleEnded() {
    this.isPlaying = false;
    this.emit('ended');
    
    if (this.autoPlay) {
      this.next();
    }
  }
  
  /**
   * Handle play event
   */
  handlePlay() {
    this.isPlaying = true;
    this.emit('statechange');
  }
  
  /**
   * Handle pause event
   */
  handlePause() {
    this.isPlaying = false;
    this.emit('statechange');
  }
  
  /**
   * Handle error
   */
  handleError(error) {
    console.error('Audio error:', error);
    this.isPlaying = false;
    this.emit('error', error);
  }
  
  /**
   * Add event listener
   * @param {string} event - Event name
   * @param {Function} callback - Callback function
   */
  on(event, callback) {
    if (!this.listeners[event]) {
      this.listeners[event] = [];
    }
    this.listeners[event].push(callback);
  }
  
  /**
   * Remove event listener
   * @param {string} event - Event name
   * @param {Function} callback - Callback function
   */
  off(event, callback) {
    if (!this.listeners[event]) return;
    this.listeners[event] = this.listeners[event].filter(cb => cb !== callback);
  }
  
  /**
   * Emit event
   * @param {string} event - Event name
   * @param {*} data - Event data
   */
  emit(event, data) {
    if (!this.listeners[event]) return;
    this.listeners[event].forEach(callback => callback(data));
  }
}

// Export singleton instance
export const audioPlayer = new AudioPlayer();
