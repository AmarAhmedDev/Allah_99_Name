/* ============================================
   HOME PAGE
   ============================================ */

import { router } from '../utils/router.js';

export async function renderHomePage() {
  const pageContent = document.getElementById('page-content');
  const pageTitle = document.getElementById('page-title');
  const backBtn = document.getElementById('back-btn');
  
  // Update header
  pageTitle.textContent = 'Asma\'ul Husna';
  backBtn.style.display = 'none';
  
  // Render home page
  pageContent.innerHTML = `
    <div class="home-page animate-fade-in">
      <!-- Mosque Icon -->
      <div class="mosque-icon">
        🕌
      </div>
      
      <!-- Title -->
      <h1 class="home-title">Asma'ul Husna</h1>
      <div class="arabic-text home-arabic-title">أَسْمَاءُ ٱللَّٰهِ ٱلْحُسْنَىٰ</div>
      
      <!-- Subtitle -->
      <p class="home-subtitle">
        Discover the 99 Beautiful Names of Allah
      </p>
      
      <!-- Main Buttons -->
      <div class="home-buttons">
        <button class="btn btn-primary btn-large" id="start-learning-btn">
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"/>
            <path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"/>
          </svg>
          Start Learning
        </button>
        
        <button class="btn btn-secondary btn-large" id="play-all-btn">
          <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
            <path d="M8 5v14l11-7z"/>
          </svg>
          Play All Names
        </button>
      </div>
      
      <!-- Feature Cards -->
      <div class="feature-cards">
        <div class="feature-card" id="practice-btn">
          <div class="feature-icon">📚</div>
          <div class="feature-title">Practice</div>
        </div>
        
        <div class="feature-card" id="tasbih-btn">
          <div class="feature-icon">📿</div>
          <div class="feature-title">Tasbih</div>
        </div>
      </div>
      
      <!-- Islamic Quote -->
      <div class="home-quote">
        "Indeed, Allah has ninety-nine names, one hundred less one. Whoever encompasses them will enter Paradise."
        <span class="quote-author">- Sahih Bukhari</span>
      </div>
    </div>
  `;
  
  // Add event listeners
  document.getElementById('start-learning-btn').addEventListener('click', () => {
    router.navigate('/names');
  });
  
  document.getElementById('play-all-btn').addEventListener('click', () => {
    router.navigate('/player');
  });
  
  document.getElementById('practice-btn').addEventListener('click', () => {
    router.navigate('/names?mode=practice');
  });
  
  document.getElementById('tasbih-btn').addEventListener('click', () => {
    // Tasbih feature - could be implemented later
    alert('Tasbih counter coming soon! 📿');
  });
}
