// Barlie Beer Rating App JavaScript

class BarlieApp {
    constructor() {
        this.currentTab = 'search';
        this.currentRating = 0;
        this.beerDatabase = this.initializeBeerDatabase();
        this.breweryDatabase = this.initializeBreweryDatabase();
        this.userRatings = this.loadUserRatings();
        
        this.initializeApp();
    }

    initializeApp() {
        this.setupEventListeners();
        this.showAllBeers();
        this.updateUserStats();
        this.updateBeerGrid('Next'); // Initialize with Next tab content
    }

    setupEventListeners() {
        // Tab navigation
        document.querySelectorAll('.nav-item').forEach(item => {
            item.addEventListener('click', (e) => {
                const tab = e.currentTarget.dataset.tab;
                this.switchTab(tab);
            });
        });

        // Search functionality
        const searchInput = document.getElementById('search-input');
        const clearSearchBtn = document.getElementById('clear-search');
        
        searchInput.addEventListener('input', (e) => {
            this.handleSearch(e.target.value);
            clearSearchBtn.style.display = e.target.value ? 'block' : 'none';
        });

        clearSearchBtn.addEventListener('click', () => {
            searchInput.value = '';
            clearSearchBtn.style.display = 'none';
            this.showNearbyBreweries();
        });

        // Category buttons
        document.querySelectorAll('.category-btn').forEach(btn => {
            btn.addEventListener('click', (e) => {
                const category = e.currentTarget.dataset.category;
                this.handleCategoryClick(category, e.currentTarget);
            });
        });

        // Barcode scanner
        document.getElementById('barcode-scanner').addEventListener('click', () => {
            this.openBarcodeModal();
        });

        // Modal controls
        document.querySelectorAll('.close-modal').forEach(btn => {
            btn.addEventListener('click', () => {
                this.closeModals();
            });
        });

        // Star rating
        document.querySelectorAll('.star-btn').forEach(btn => {
            btn.addEventListener('click', (e) => {
                const rating = parseInt(e.currentTarget.dataset.rating);
                this.setRating(rating);
            });
        });

        // Save rating
        document.querySelector('.save-rating-btn').addEventListener('click', () => {
            this.saveRating();
        });

        // Add to list
        document.querySelector('.add-to-list-btn').addEventListener('click', () => {
            this.addToList();
        });

        // Scanner actions
        document.querySelector('.scan-btn').addEventListener('click', () => {
            this.simulateBarcodeScan();
        });

        document.querySelector('.manual-entry-btn').addEventListener('click', () => {
            this.openManualEntry();
        });

        // Brewery cards
        document.addEventListener('click', (e) => {
            if (e.target.closest('.brewery-card')) {
                const breweryId = e.target.closest('.brewery-card').dataset.breweryId;
                this.showBreweryDetail(breweryId);
            }
        });

        // New profile interactions
        this.setupProfileInteractions();

        // Close modals on outside click
        document.addEventListener('click', (e) => {
            if (e.target.classList.contains('modal')) {
                this.closeModals();
            }
        });
    }

    switchTab(tab) {
        // Update navigation
        document.querySelectorAll('.nav-item').forEach(item => {
            item.classList.toggle('active', item.dataset.tab === tab);
        });

        // Update tab content
        document.querySelectorAll('.tab-content').forEach(content => {
            content.classList.toggle('active', content.id === `${tab}-tab`);
        });

        // Hide/show profile header based on tab
        const profileHeader = document.querySelector('.profile-header-new');
        const userStatsBar = document.querySelector('.user-stats-bar');
        
        if (tab === 'profile') {
            if (profileHeader) profileHeader.style.display = 'none';
            if (userStatsBar) userStatsBar.style.display = 'none';
        } else {
            if (profileHeader) profileHeader.style.display = 'block';
            if (userStatsBar) userStatsBar.style.display = 'flex';
        }

        // Update page title
        const pageTitle = document.getElementById('page-title');
        if (tab === 'search') {
            pageTitle.innerHTML = `
                <div class="discover-header-main">
                    <i class="fas fa-search search-icon-header"></i>
                    <div class="discover-center">
                        <div class="discover-title">Discover</div>
                    </div>
                </div>
            `;
        } else if (tab === 'profile') {
            pageTitle.innerHTML = `
                <div class="profile-header-main">
                    <i class="fas fa-search search-icon-header"></i>
                    <div class="profile-center">
                        <img src="data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTAwIiBoZWlnaHQ9IjEwMCIgdmlld0JveD0iMCAwIDEwMCAxMDAiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CjxyZWN0IHdpZHRoPSIxMDAiIGhlaWdodD0iMTAwIiBmaWxsPSIjMDA3QUZGIi8+CjxwYXRoIGQ9Ik00MCA2MEM0MCA0Ni43NDUyIDUwLjc0NTIgMzYgNjQgMzZDNzcuMjU0OCAzNiA4OCA0Ni43NDUyIDg4IDYwVjgwSDQwVjYwWiIgZmlsbD0id2hpdGUiLz4KPHBhdGggZD0iTTMwIDkwQzMwIDc4LjQwNDYgMzkuNDA0NiA2OSA1MSA2OUg3N0M4OC41OTU0IDY5IDk4IDc4LjQwNDYgOTggOTBWOTJIMzBWOTBaIiBmaWxsPSJ3aGl0ZSIvPgo8L3N2Zz4K" alt="Profile" class="profile-image-main">
                        <div class="profile-info-main">
                            <div class="profile-name-main">Rome</div>
                            <div class="profile-handle-main">@romandenson</div>
                        </div>
                    </div>
                </div>
            `;
        }

        this.currentTab = tab;
    }

    handleSearch(query) {
        if (!query.trim()) {
            this.showAllBeers();
            return;
        }

        const results = this.searchBeers(query);
        this.displayBeerResults(results, query);
    }

    searchBeers(query) {
        const lowerQuery = query.toLowerCase();
        
        return this.beerDatabase.filter(beer => 
            beer.name.toLowerCase().includes(lowerQuery) ||
            beer.brewery.toLowerCase().includes(lowerQuery) ||
            beer.style.toLowerCase().includes(lowerQuery)
        );
    }

    displayBeerResults(beers, query) {
        const allBeersDiv = document.getElementById('all-beers');
        
        if (beers.length > 0) {
            allBeersDiv.innerHTML = `
                <h2 class="section-title">Search Results for "${query}" (${beers.length})</h2>
                ${beers.map(beer => this.createBeerCard(beer)).join('')}
            `;
        } else {
            allBeersDiv.innerHTML = `
                <h2 class="section-title">No beers found for "${query}"</h2>
                <p style="text-align: center; color: #8e8e93; margin-top: 20px;">Try searching by brewery name, beer name, or style</p>
            `;
        }
    }

    createBeerCard(beer) {
        return `
            <div class="beer-card-discover" onclick="app.openBeerDetail('${beer.id}')">
                <div class="beer-thumbnail">
                    <div class="beer-image-placeholder">
                        <i class="fas fa-beer"></i>
                    </div>
                </div>
                <div class="beer-info">
                    <h3 class="beer-title">${beer.name}</h3>
                    <p class="beer-caption">${beer.brewery} • ${beer.style}</p>
                </div>
                <div class="beer-actions">
                    <button class="next-btn">+Next</button>
                </div>
            </div>
        `;
    }

    createBreweryCard(brewery) {
        return `
            <div class="brewery-card" onclick="app.showBreweryDetail('${brewery.id}')">
                <div class="brewery-image">
                    <i class="fas fa-industry"></i>
                </div>
                <div class="brewery-info">
                    <h3 class="brewery-name">${brewery.name}</h3>
                    <p class="brewery-address">${brewery.address}</p>
                    <p class="brewery-type">${brewery.type}</p>
                    <div class="brewery-distance">${brewery.distance}</div>
                </div>
                <div class="brewery-actions">
                    <button class="visit-btn">Visit</button>
                </div>
            </div>
        `;
    }

    handleCategoryClick(category, button) {
        // Update active category button
        document.querySelectorAll('.category-btn').forEach(btn => {
            btn.classList.remove('active');
        });
        button.classList.add('active');

        // Show appropriate content
        switch (category) {
            case 'all':
                this.showAllBeers();
                break;
            case 'ipa':
                this.showBeersByStyle('IPA');
                break;
            case 'stout':
                this.showBeersByStyle('Stout');
                break;
            case 'lager':
                this.showBeersByStyle('Lager');
                break;
            case 'pilsner':
                this.showBeersByStyle('Pilsner');
                break;
        }
    }

    showAllBeers() {
        const allBeersDiv = document.getElementById('all-beers');
        allBeersDiv.innerHTML = `
            <h2 class="section-title">All Beers</h2>
            ${this.beerDatabase.map(beer => this.createBeerCard(beer)).join('')}
        `;
    }

    showBeersByStyle(style) {
        const beersInStyle = this.beerDatabase.filter(beer => beer.style.toLowerCase() === style.toLowerCase());
        const allBeersDiv = document.getElementById('all-beers');
        
        allBeersDiv.innerHTML = `
            <h2 class="section-title">${style} Beers</h2>
            ${beersInStyle.length > 0 ? 
                beersInStyle.map(beer => this.createBeerCard(beer)).join('') :
                `<p style="text-align: center; color: #8e8e93; margin-top: 20px;">No ${style} beers found</p>`
            }
        `;
    }

    openBeerDetail(beerId) {
        const beer = this.beerDatabase.find(b => b.id === beerId);
        if (!beer) return;

        document.getElementById('modal-beer-name').textContent = beer.name;
        document.querySelector('.brewery-name').textContent = beer.brewery;
        document.querySelector('.beer-style').textContent = `${beer.style} • ${beer.abv}% ABV`;
        
        // Reset rating
        this.currentRating = this.userRatings[beerId]?.rating || 0;
        this.updateStarDisplay();
        
        // Set review text
        document.getElementById('review-text').value = this.userRatings[beerId]?.review || '';
        
        document.getElementById('beer-detail-modal').classList.add('active');
    }

    showBreweryDetail(breweryId) {
        const brewery = this.breweryDatabase.find(b => b.id === breweryId);
        if (!brewery) return;

        // For now, just show an alert. In a real app, this would open a brewery detail modal
        alert(`Brewery: ${brewery.name}\nAddress: ${brewery.address}\nType: ${brewery.type}`);
    }

    openBarcodeModal() {
        document.getElementById('barcode-modal').classList.add('active');
    }

    closeModals() {
        document.querySelectorAll('.modal').forEach(modal => {
            modal.classList.remove('active');
        });
    }

    setRating(rating) {
        this.currentRating = rating;
        this.updateStarDisplay();
    }

    updateStarDisplay() {
        document.querySelectorAll('.star-btn').forEach((btn, index) => {
            const starIcon = btn.querySelector('i');
            if (index < this.currentRating) {
                btn.classList.add('active');
                starIcon.className = 'fas fa-star';
            } else {
                btn.classList.remove('active');
                starIcon.className = 'far fa-star';
            }
        });
    }

    saveRating() {
        const reviewText = document.getElementById('review-text').value;
        const beerName = document.getElementById('modal-beer-name').textContent;
        
        // Find beer ID from name
        const beer = this.beerDatabase.find(b => b.name === beerName);
        if (!beer) return;

        // Save rating
        this.userRatings[beer.id] = {
            rating: this.currentRating,
            review: reviewText,
            date: new Date().toISOString()
        };

        // Save to localStorage
        localStorage.setItem('barlie_user_ratings', JSON.stringify(this.userRatings));

        // Update UI
        this.updateUserStats();
        this.closeModals();

        // Show success message
        this.showToast('Rating saved successfully!');
    }

    addToList() {
        const beerName = document.getElementById('modal-beer-name').textContent;
        // In a real app, this would show a list selection modal
        this.showToast(`Added "${beerName}" to your lists!`);
    }

    simulateBarcodeScan() {
        // Simulate barcode scan with random beer
        const randomBeer = this.beerDatabase[Math.floor(Math.random() * this.beerDatabase.length)];
        
        this.closeModals();
        this.openBeerDetail(randomBeer.id);
        
        this.showToast(`Scanned: ${randomBeer.name}`);
    }

    openManualEntry() {
        this.closeModals();
        // In a real app, this would open a manual beer entry form
        this.showToast('Manual entry form would open here');
    }

    openList(listType) {
        if (listType === 'custom') {
            this.showToast('Create new list feature coming soon!');
            return;
        }

        // Filter beers based on list type
        let filteredBeers = [];
        switch (listType) {
            case 'favorites':
                filteredBeers = this.beerDatabase.filter(beer => 
                    this.userRatings[beer.id]?.rating >= 4
                );
                break;
            case 'want-to-try':
                // In a real app, this would be a separate list
                filteredBeers = this.beerDatabase.slice(0, 5);
                break;
            case 'recent':
                filteredBeers = this.beerDatabase.slice(0, 8);
                break;
        }

        this.showToast(`${listType} list: ${filteredBeers.length} beers`);
    }

    handleQuickAction(action) {
        switch (action) {
            case 'Rate Beer':
                this.switchTab('search');
                break;
            case 'My Lists':
                // Lists are already visible in profile
                break;
            case 'Analytics':
                this.showToast('Analytics feature coming soon!');
                break;
        }
    }

    updateUserStats() {
        const totalBeers = Object.keys(this.userRatings).length;
        const totalRating = Object.values(this.userRatings).reduce((sum, rating) => sum + rating.rating, 0);
        const avgRating = totalBeers > 0 ? (totalRating / totalBeers).toFixed(1) : '0.0';

        document.querySelector('.stat-number').textContent = totalBeers;
        document.querySelectorAll('.stat-number')[1].textContent = avgRating;
    }

    loadUserRatings() {
        const saved = localStorage.getItem('barlie_user_ratings');
        return saved ? JSON.parse(saved) : {};
    }

    showToast(message) {
        // Create toast notification
        const toast = document.createElement('div');
        toast.className = 'toast';
        toast.textContent = message;
        toast.style.cssText = `
            position: fixed;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            background: #1d1d1f;
            color: white;
            padding: 16px 24px;
            border-radius: 12px;
            font-size: 16px;
            z-index: 2000;
            animation: toastFadeIn 0.3s ease-out;
        `;

        document.body.appendChild(toast);

        setTimeout(() => {
            toast.style.animation = 'toastFadeOut 0.3s ease-out';
            setTimeout(() => {
                document.body.removeChild(toast);
            }, 300);
        }, 2000);
    }

    initializeBeerDatabase() {
        return [
            {
                id: '1',
                name: 'Octoberfest',
                brewery: 'Sam Adams',
                style: 'Märzen',
                abv: '5.3',
                description: 'Traditional German Märzen lager with rich malt flavor.'
            },
            {
                id: '2',
                name: 'Boston Lager',
                brewery: 'Sam Adams',
                style: 'Lager',
                abv: '5.0',
                description: 'Classic American lager with balanced hops and malt.'
            },
            {
                id: '3',
                name: 'Heineken',
                brewery: 'Heineken',
                style: 'Pilsner',
                abv: '5.0',
                description: 'Crisp European pilsner with distinctive hop character.'
            },
            {
                id: '4',
                name: 'Stella Artois',
                brewery: 'Stella Artois',
                style: 'Pilsner',
                abv: '5.2',
                description: 'Premium Belgian pilsner with smooth finish.'
            },
            {
                id: '5',
                name: 'Guinness Draught',
                brewery: 'Guinness',
                style: 'Stout',
                abv: '4.2',
                description: 'Iconic Irish dry stout with creamy head.'
            },
            {
                id: '6',
                name: 'Corona Extra',
                brewery: 'Corona',
                style: 'Lager',
                abv: '4.6',
                description: 'Light Mexican lager perfect with lime.'
            },
            {
                id: '7',
                name: 'Sierra Nevada Pale Ale',
                brewery: 'Sierra Nevada',
                style: 'Pale Ale',
                abv: '5.6',
                description: 'Pioneering American pale ale with Cascade hops.'
            },
            {
                id: '8',
                name: 'Blue Moon',
                brewery: 'Blue Moon',
                style: 'Witbier',
                abv: '5.4',
                description: 'Belgian-style wheat ale with orange peel and coriander.'
            },
            {
                id: '9',
                name: 'Budweiser',
                brewery: 'Budweiser',
                style: 'Lager',
                abv: '5.0',
                description: 'American lager known as the King of Beers.'
            },
            {
                id: '10',
                name: 'Coors Light',
                brewery: 'Coors',
                style: 'Lager',
                abv: '4.2',
                description: 'Light American lager with crisp, clean taste.'
            },
            {
                id: '11',
                name: 'Miller Lite',
                brewery: 'Miller',
                style: 'Lager',
                abv: '4.2',
                description: 'Light American lager with great taste, less filling.'
            },
            {
                id: '12',
                name: 'Dos Equis',
                brewery: 'Dos Equis',
                style: 'Lager',
                abv: '4.9',
                description: 'Mexican lager with distinctive amber color.'
            }
        ];
    }

    initializeBreweryDatabase() {
        return [
            {
                id: '1',
                name: 'Craft & Barrel Brewing',
                address: '123 Main St, Downtown',
                type: 'Microbrewery',
                distance: '0.8 miles away'
            },
            {
                id: '2',
                name: 'Hoppy Trails Brewery',
                address: '456 Oak Ave, Midtown',
                type: 'Brewpub',
                distance: '1.2 miles away'
            },
            {
                id: '3',
                name: 'Golden Hops Taproom',
                address: '789 Pine St, Uptown',
                type: 'Taproom',
                distance: '2.1 miles away'
            }
        ];
    }

    setupProfileInteractions() {
        // Action buttons
        document.querySelectorAll('.action-btn-new').forEach(btn => {
            btn.addEventListener('click', (e) => {
                const action = e.currentTarget.textContent.trim();
                this.handleProfileAction(action);
            });
        });

        // Content categories
        document.querySelectorAll('.category-item').forEach(item => {
            item.addEventListener('click', (e) => {
                document.querySelectorAll('.category-item').forEach(cat => cat.classList.remove('active'));
                e.currentTarget.classList.add('active');
                const category = e.currentTarget.textContent.trim();
                this.filterBeerGrid(category);
            });
        });

        // Beer grid cards
        document.querySelectorAll('.beer-card-new').forEach(card => {
            card.addEventListener('click', (e) => {
                const beerId = e.currentTarget.dataset.beerId;
                this.openBeerDetail(beerId);
            });
        });

        // Add more card
        document.querySelector('.add-more-card').addEventListener('click', () => {
            this.switchTab('search');
            this.showToast('Switch to Search tab to discover more beers!');
        });

        // Interactive buttons
        document.querySelectorAll('.interactive-btn').forEach(btn => {
            btn.addEventListener('click', (e) => {
                const action = e.currentTarget.textContent.trim();
                this.handleInteractiveAction(action);
            });
        });

        // Filter pills
        document.querySelectorAll('.filter-pill').forEach(pill => {
            pill.addEventListener('click', (e) => {
                document.querySelectorAll('.filter-pill').forEach(p => p.classList.remove('active'));
                e.currentTarget.classList.add('active');
                const filter = e.currentTarget.textContent.trim();
                this.applyFilter(filter);
            });
        });
    }

    handleProfileAction(action) {
        switch (action) {
            case 'Activity':
                this.showToast('Activity feed coming soon!');
                break;
            case 'Share':
                this.shareProfile();
                break;
            case 'Settings':
                this.showToast('Settings panel coming soon!');
                break;
        }
    }

    filterBeerGrid(category) {
        this.updateBeerGrid(category);
    }

    updateBeerGrid(activeCategory) {
        const beerGrid = document.querySelector('.beer-grid');
        const addMoreCard = beerGrid.querySelector('.add-more-card');
        
        // Remove all existing cards
        const existingBeerCards = beerGrid.querySelectorAll('.beer-card-new');
        const existingListCards = beerGrid.querySelectorAll('.list-card-wide, .create-list-card');
        existingBeerCards.forEach(card => card.remove());
        existingListCards.forEach(card => card.remove());
        
        // Reset grid layout
        beerGrid.classList.remove('lists-layout');
        addMoreCard.style.display = 'flex';
        
        if (activeCategory === 'Lists') {
            // Show lists layout instead of beer cards
            this.showListsLayout(beerGrid, addMoreCard);
            return;
        }
        
        let beersToShow = [];
        
        switch(activeCategory) {
            case 'Next':
                beersToShow = this.beerDatabase.filter(beer => 
                    !this.userRatings[beer.id] || this.userRatings[beer.id].rating === 0
                );
                break;
            case 'Drank':
                beersToShow = this.beerDatabase.filter(beer => 
                    this.userRatings[beer.id] && this.userRatings[beer.id].rating > 0
                );
                break;
        }
        
        // Add beer cards to the grid
        beersToShow.slice(0, 4).forEach(beer => {
            const beerCard = this.createBeerCardForGrid(beer);
            beerGrid.insertBefore(beerCard, addMoreCard);
        });
        
        // Update add-more card text based on category
        const addMoreText = addMoreCard.querySelector('span');
        switch(activeCategory) {
            case 'Next':
                addMoreText.textContent = 'Add to Next';
                break;
            case 'Drank':
                addMoreText.textContent = 'Rate More';
                break;
        }
    }

    showListsLayout(beerGrid, addMoreCard) {
        // Hide the add-more card for lists
        addMoreCard.style.display = 'none';
        
        // Remove any existing list cards
        const existingListCards = beerGrid.querySelectorAll('.list-card-wide, .create-list-card');
        existingListCards.forEach(card => card.remove());
        
        // Add lists-layout class to beer grid
        beerGrid.classList.add('lists-layout');
        
        // Create wide list cards
        const listCards = [
            {
                name: 'Summer Beers',
                count: 8,
                icon: 'fas fa-sun',
                color: '#ff6b35'
            },
            {
                name: 'IPA Collection',
                count: 12,
                icon: 'fas fa-leaf',
                color: '#34c759'
            },
            {
                name: 'Dark & Rich',
                count: 6,
                icon: 'fas fa-coffee',
                color: '#8e44ad'
            }
        ];
        
        listCards.forEach(list => {
            const listCard = document.createElement('div');
            listCard.className = 'list-card-wide';
            listCard.innerHTML = `
                <div class="list-icon-large" style="background: ${list.color}">
                    <i class="${list.icon}"></i>
                </div>
                <div class="list-info-wide">
                    <h3 class="list-name-wide">${list.name}</h3>
                    <p class="list-count-wide">${list.count} beers</p>
                </div>
                <div class="list-arrow-wide">
                    <i class="fas fa-chevron-right"></i>
                </div>
            `;
            
            listCard.addEventListener('click', () => {
                this.showToast(`Opening ${list.name} list`);
            });
            
            beerGrid.appendChild(listCard);
        });
        
        // Create new list card
        const createListCard = document.createElement('div');
        createListCard.className = 'create-list-card';
        createListCard.innerHTML = `
            <div class="create-list-icon">
                <i class="fas fa-plus"></i>
            </div>
            <div class="create-list-content">
                <span>Create New List</span>
            </div>
        `;
        
        createListCard.addEventListener('click', () => {
            this.showToast('Create new list feature coming soon!');
        });
        
        beerGrid.appendChild(createListCard);
    }

    createBeerCardForGrid(beer) {
        const userRating = this.userRatings[beer.id];
        const rating = userRating ? userRating.rating : 0;
        
        const card = document.createElement('div');
        card.className = 'beer-card-new';
        card.dataset.beerId = beer.id;
        
        const stars = this.generateStarsHTML(rating);
        
        card.innerHTML = `
            <div class="beer-poster">
                <div class="beer-image-placeholder">
                    <i class="fas fa-beer"></i>
                </div>
            </div>
        `;
        
        // Add click event listener
        card.addEventListener('click', () => {
            this.openBeerDetail(beer.id);
        });
        
        return card;
    }

    generateStarsHTML(rating) {
        let starsHTML = '';
        for (let i = 1; i <= 5; i++) {
            if (i <= rating) {
                starsHTML += '<i class="fas fa-star"></i>';
            } else {
                starsHTML += '<i class="far fa-star"></i>';
            }
        }
        return starsHTML;
    }

    handleInteractiveAction(action) {
        switch (action) {
            case 'Rate Random':
                this.switchTab('search');
                this.simulateBarcodeScan();
                break;
            case 'Discover':
                this.switchTab('search');
                this.showToast('Discover new beers in the Search tab!');
                break;
        }
    }

    applyFilter(filter) {
        // In a real app, this would filter the beer grid
        this.showToast(`Filter applied: ${filter}`);
    }

    shareProfile() {
        if (navigator.share) {
            navigator.share({
                title: 'My Beer Profile - Barlie',
                text: 'Check out my beer ratings and discoveries on Barlie!',
                url: window.location.href
            });
        } else {
            this.showToast('Profile shared! (Copy link functionality)');
        }
    }
}

// CSS for toast animations
const toastStyles = document.createElement('style');
toastStyles.textContent = `
    @keyframes toastFadeIn {
        from {
            opacity: 0;
            transform: translate(-50%, -60%);
        }
        to {
            opacity: 1;
            transform: translate(-50%, -50%);
        }
    }
    
    @keyframes toastFadeOut {
        from {
            opacity: 1;
            transform: translate(-50%, -50%);
        }
        to {
            opacity: 0;
            transform: translate(-50%, -40%);
        }
    }
`;
document.head.appendChild(toastStyles);

// Initialize app when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    window.app = new BarlieApp();
});
