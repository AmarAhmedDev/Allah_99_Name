/* ============================================
   NAMES LIST PAGE
   ============================================ */

import { router } from '../utils/router.js';
import { audioPlayer } from '../audio-player.js';

let allNames = [];
let filteredNames = [];

export async function renderNamesListPage() {
  const pageContent = document.getElementById('page-content');
  const pageTitle = document.getElementById('page-title');
  const backBtn = document.getElementById('back-btn');
  
  // Update header
  pageTitle.textContent = '99 Names of Allah';
  backBtn.style.display = 'flex';
  
  // Load names data
  if (allNames.length === 0) {
    await loadNamesData();
  }
  
  filteredNames = [...allNames];
  
  // Render page
  renderNamesGrid();
  
  // Set up back button
  backBtn.onclick = () => router.navigate('/');
}

async function loadNamesData() {
  try {
    const response = await fetch('data/names.json');
    const data = await response.json();
    allNames = data.names;
    
    // Set playlist for audio player
    audioPlayer.setPlaylist(allNames);
  } catch (error) {
    console.error('Error loading names:', error);
    allNames = [];
  }
}

function renderNamesGrid() {
  const pageContent = document.getElementById('page-content');
  
  pageContent.innerHTML = `
    <div class="animate-fade-in">
      <!-- Search Bar -->
      <div class="search-container">
        <svg class="search-icon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <circle cx="11" cy="11" r="8"/>
          <path d="m21 21-4.35-4.35"/>
        </svg>
        <input 
          type="text" 
          class="search-bar" 
          id="search-input" 
          placeholder="Search names..."
          autocomplete="off"
        />
      </div>
      
      <!-- Names Grid -->
      <div class="names-grid" id="names-grid">
        ${renderNameCards()}
      </div>
      
      <!-- Empty State -->
      <div id="empty-state" class="empty-state" style="display: none;">
        <div class="empty-icon">🔍</div>
        <div class="empty-message">No names found</div>
      </div>
    </div>
    
    <!-- Floating Play All Button -->
    <button class="fab" id="fab-play-all" title="Play All Names">
      <svg width="24" height="24" viewBox="0 0 24 24" fill="currentColor">
        <path d="M8 5v14l11-7z"/>
      </svg>
    </button>
  `;
  
  // Add event listeners
  setupEventListeners();
}

function renderNameCards() {
  if (filteredNames.length === 0) {
    return '';
  }
  
  return filteredNames.map((name, index) => `
    <div class="card name-card stagger-item" data-id="${name.id}">
      <div class="name-number">${name.id}</div>
      <div class="arabic-text name-arabic">${name.arabic}</div>
      <div class="name-transliteration">${name.transliteration}</div>
      <div class="name-meaning">${name.meaning_en}</div>
      
      <div class="card-footer">
        <button class="play-btn-small" data-id="${name.id}" title="Play audio">
          <svg viewBox="0 0 24 24">
            <path d="M8 5v14l11-7z"/>
          </svg>
        </button>
      </div>
    </div>
  `).join('');
}

function setupEventListeners() {
  // Search functionality
  const searchInput = document.getElementById('search-input');
  if (searchInput) {
    searchInput.addEventListener('input', handleSearch);
  }
  
  // Name card clicks
  const nameCards = document.querySelectorAll('.name-card');
  nameCards.forEach(card => {
    card.addEventListener('click', (e) => {
      // Don't navigate if clicking play button
      if (e.target.closest('.play-btn-small')) {
        return;
      }
      const id = card.dataset.id;
      router.navigate(`/detail/${id}`);
    });
  });
  
  // Play buttons
  const playButtons = document.querySelectorAll('.play-btn-small');
  playButtons.forEach(btn => {
    btn.addEventListener('click', async (e) => {
      e.stopPropagation();
      const id = parseInt(btn.dataset.id);
      const index = allNames.findIndex(n => n.id === id);
      if (index !== -1) {
        await audioPlayer.playByIndex(index);
        highlightPlayingCard(id);
      }
    });
  });
  
  // FAB - Play All
  const fabPlayAll = document.getElementById('fab-play-all');
  if (fabPlayAll) {
    fabPlayAll.addEventListener('click', () => {
      router.navigate('/player');
    });
  }
}

function handleSearch(e) {
  const query = e.target.value.toLowerCase().trim();
  const emptyState = document.getElementById('empty-state');
  const grid = document.getElementById('names-grid');
  
  if (query === '') {
    filteredNames = [...allNames];
  } else {
    filteredNames = allNames.filter(name => 
      name.transliteration.toLowerCase().includes(query) ||
      name.meaning_en.toLowerCase().includes(query) ||
      name.arabic.includes(query)
    );
  }
  
  // Update grid
  if (filteredNames.length === 0) {
    grid.style.display = 'none';
    emptyState.style.display = 'block';
  } else {
    grid.style.display = 'grid';
    emptyState.style.display = 'none';
    grid.innerHTML = renderNameCards();
    setupEventListeners();
  }
}

function highlightPlayingCard(id) {
  // Remove previous highlights
  document.querySelectorAll('.name-card').forEach(card => {
    card.classList.remove('is-playing');
  });
  
  // Add highlight to current
  const currentCard = document.querySelector(`.name-card[data-id="${id}"]`);
  if (currentCard) {
    currentCard.classList.add('is-playing');
  }
}

// Export for use in other modules
export { allNames };
