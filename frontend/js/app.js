// ===== PLANT HEALTH MONITOR - APPLICATION LOGIC =====

// Global state
let plantData = null;
let charts = {};
let currentFilter = '7d';
let refreshInterval = null;

// API Configuration
const API_BASE_URL = '/api';
const USE_MOCK_DATA = true; // Set to false when backend is ready

// ===== INITIALIZATION =====
document.addEventListener('DOMContentLoaded', () => {
    initializeApp();
});

async function initializeApp() {
    setupEventListeners();
    await fetchPlantData(true); // Show spinner on initial load
    startAutoRefresh();
}

// ===== EVENT LISTENERS =====
function setupEventListeners() {
    // Navigation
    document.getElementById('editPlantBtn').addEventListener('click', showConfigScreen);
    document.getElementById('backBtn').addEventListener('click', showHomeScreen);
    document.getElementById('cancelBtn').addEventListener('click', showHomeScreen);

    // Modal controls
    document.getElementById('viewHistoricalDataBtn').addEventListener('click', openHistoricalModal);
    document.getElementById('closeHistoricalBtn').addEventListener('click', closeHistoricalModal);
    document.getElementById('viewWateringHistoryBtn').addEventListener('click', openWateringModal);
    document.getElementById('closeWateringBtn').addEventListener('click', closeWateringModal);

    // Close modals on background click
    document.getElementById('historicalModal').addEventListener('click', (e) => {
        if (e.target.id === 'historicalModal') closeHistoricalModal();
    });
    document.getElementById('wateringModal').addEventListener('click', (e) => {
        if (e.target.id === 'wateringModal') closeWateringModal();
    });

    // Time filter buttons
    document.querySelectorAll('.filter-btn').forEach(btn => {
        btn.addEventListener('click', (e) => {
            currentFilter = e.target.dataset.filter;
            updateTimeFilter(e.target);
            updateCharts();
        });
    });

    // Plant type select - show custom input
    document.getElementById('inputPlantType').addEventListener('change', (e) => {
        const customGroup = document.getElementById('customPlantTypeGroup');
        if (e.target.value === 'custom') {
            customGroup.classList.remove('hidden');
        } else {
            customGroup.classList.add('hidden');
        }
    });

    // Photo upload preview
    document.getElementById('inputPlantPhoto').addEventListener('change', handlePhotoPreview);

    // Form submit
    document.getElementById('plantConfigForm').addEventListener('submit', handleFormSubmit);
}

// ===== SCREEN NAVIGATION =====
function showHomeScreen() {
    document.getElementById('homeScreen').classList.add('active');
    document.getElementById('configScreen').classList.remove('active');
}

function showConfigScreen() {
    document.getElementById('homeScreen').classList.remove('active');
    document.getElementById('configScreen').classList.add('active');
    populateConfigForm();
}

// ===== MODAL CONTROLS =====
function openHistoricalModal() {
    document.getElementById('historicalModal').classList.remove('hidden');
    // Render charts when modal opens
    renderCharts();
}

function closeHistoricalModal() {
    document.getElementById('historicalModal').classList.add('hidden');
}

function openWateringModal() {
    document.getElementById('wateringModal').classList.remove('hidden');
    renderWateringLog();
}

function closeWateringModal() {
    document.getElementById('wateringModal').classList.add('hidden');
}

// ===== DATA FETCHING =====
async function fetchPlantData(showSpinner = false) {
    // Only show loading spinner on initial load, not on auto-refresh
    if (showSpinner) {
        showLoading(true);
    }

    try {
        let data;

        if (USE_MOCK_DATA) {
            // Fetch mock data from local JSON file
            const response = await fetch('mock-data.json');
            data = await response.json();
        } else {
            // Fetch from actual backend API
            const response = await fetch(`${API_BASE_URL}/plant-data`);
            data = await response.json();
        }

        plantData = data;
        renderDashboard();
        renderCareSheet();

    } catch (error) {
        console.error('Error fetching plant data:', error);
        // Use cached data if available
        if (plantData) {
            console.log('Using cached data');
            renderDashboard();
        } else {
            showError('Failed to load plant data. Please check your connection.');
        }
    } finally {
        if (showSpinner) {
            showLoading(false);
        }
    }
}

// ===== DASHBOARD RENDERING =====
function renderDashboard() {
    if (!plantData) return;

    renderHeader();
    renderPlantProfile();
    renderRecommendation();
    renderWateringPrediction();
    renderSensorData();
}

// Render Header
function renderHeader() {
    const { device } = plantData;

    // Device status
    const statusIcon = document.getElementById('deviceStatusIcon');
    const statusText = document.getElementById('deviceStatusText');

    if (device.status === 'online') {
        statusIcon.textContent = '📶';
        statusText.textContent = 'Online';
    } else {
        statusIcon.textContent = '❌';
        statusText.textContent = 'Offline';
    }

    // Last reading timestamp
    const lastReading = new Date(device.lastReading);
    document.getElementById('lastReadingText').textContent = formatTimestamp(lastReading);
}

// Render Plant Profile
function renderPlantProfile() {
    const { plant } = plantData;

    // Plant photo
    const plantPhoto = document.getElementById('plantPhoto');
    plantPhoto.src = plant.photoUrl || 'data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" width="100" height="100"><text y="50" font-size="60">🌱</text></svg>';
    plantPhoto.alt = plant.photoAlt || 'Plant photo';

    // Plant name
    document.getElementById('plantName').textContent = plant.name;

    // Plant nickname
    const nicknameElement = document.getElementById('plantNickname');
    if (plant.nickname) {
        nicknameElement.textContent = `"${plant.nickname}"`;
        nicknameElement.style.display = 'block';
    } else {
        nicknameElement.style.display = 'none';
    }

    // Plant type
    const typeEmoji = getPlantTypeEmoji(plant.type);
    document.getElementById('plantType').textContent = `${typeEmoji} ${capitalizeFirst(plant.type)}`;

    // Plant age
    const ageUnit = plant.ageUnit || 'months';
    if (plant.age) {
        document.getElementById('plantAge').textContent = `${plant.age} ${ageUnit} old`;
    } else {
        document.getElementById('plantAge').textContent = '';
    }
}

// Render Recommendation
function renderRecommendation() {
    const { recommendation, llmInsights } = plantData;

    // Status emoticon
    document.getElementById('statusEmoticon').textContent = recommendation.statusEmoticon;

    // Action label
    const actionLabels = {
        'DO_NOT_WATER': 'Happy Plant! No Water Needed',
        'NEED_WATER': 'Thirsty Plant! Water Now',
        'SOON_TO_WATER': 'Water Soon',
        'ROOT_ROT_RISK': 'Plant in Danger! Root Rot Risk'
    };
    document.getElementById('actionLabel').textContent = actionLabels[recommendation.action] || recommendation.action;

    // Human-friendly advice
    document.getElementById('humanFriendlyAdvice').textContent = recommendation.humanFriendly;

    // Context note
    document.getElementById('contextNote').textContent = llmInsights.contextNote;

    // Warning banner
    const warningBanner = document.getElementById('warningBanner');
    if (recommendation.warning) {
        document.getElementById('warningText').textContent = recommendation.warning;
        warningBanner.classList.remove('hidden');
    } else {
        warningBanner.classList.add('hidden');
    }
}

// Render Watering Prediction
function renderWateringPrediction() {
    const { llmInsights } = plantData;

    // Next watering time
    const nextWatering = new Date(llmInsights.nextWateringTime);
    document.getElementById('nextWateringTime').textContent = formatDateTime(nextWatering);

    // Countdown timer
    updateCountdown();

    // Watering amount
    document.getElementById('wateringAmount').textContent = llmInsights.wateringAmount;

    // Evaporation rate
    document.getElementById('evaporationRate').textContent =
        `Evaporation rate: ${llmInsights.evaporationRate}${llmInsights.evaporationUnit} — soil moisture will last longer`;
}

// Update Countdown Timer
function updateCountdown() {
    if (!plantData) return;

    const { llmInsights } = plantData;
    const nextWatering = new Date(llmInsights.nextWateringTime);
    const now = new Date();
    const diff = nextWatering - now;

    if (diff <= 0) {
        document.getElementById('countdownTimer').textContent = 'Water now!';
        return;
    }

    const days = Math.floor(diff / (1000 * 60 * 60 * 24));
    const hours = Math.floor((diff % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
    const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));

    let countdown = '';
    if (days > 0) countdown += `${days}d `;
    if (hours > 0 || days > 0) countdown += `${hours}h `;
    if (days === 0 && hours === 0) countdown += `${minutes}m`;

    document.getElementById('countdownTimer').textContent = countdown.trim();
}

// Render Sensor Data
function renderSensorData() {
    const { sensorReadings } = plantData;

    // Soil Moisture
    document.getElementById('soilMoistureValue').textContent =
        `${sensorReadings.soilMoisture.percentage}${sensorReadings.soilMoisture.unit}`;
    document.getElementById('soilMoistureRef').textContent = sensorReadings.soilMoisture.llmReference;

    // Air Temperature
    document.getElementById('airTempValue').textContent =
        `${sensorReadings.airTemperature.value}${sensorReadings.airTemperature.unit}`;
    document.getElementById('airTempRef').textContent = sensorReadings.airTemperature.llmReference;

    // Air Humidity
    document.getElementById('airHumidityValue').textContent =
        `${sensorReadings.airHumidity.percentage}${sensorReadings.airHumidity.unit}`;
    document.getElementById('airHumidityRef').textContent = sensorReadings.airHumidity.llmReference;

    // Light Level
    document.getElementById('lightLevelValue').textContent =
        `${sensorReadings.lightLevel.percentage}${sensorReadings.lightLevel.unit}`;
    document.getElementById('lightLevelRef').textContent = sensorReadings.lightLevel.llmReference;
}

// ===== CHARTS RENDERING =====
function renderCharts() {
    if (!plantData || !plantData.historicalData) return;

    const { sensorLogs } = plantData.historicalData;

    // Filter data based on current time filter
    const filteredData = filterHistoricalData(sensorLogs);

    // Render each chart
    renderChart('soilMoistureChart', filteredData.soilMoisture, 'Soil Moisture (%)', 'noDataSoilMoisture');
    renderChart('airTempChart', filteredData.airTemperature, 'Air Temperature (°C)', 'noDataAirTemp');
    renderChart('airHumidityChart', filteredData.airHumidity, 'Air Humidity (%)', 'noDataAirHumidity');
    renderChart('lightLevelChart', filteredData.lightLevel, 'Light Level (%)', 'noDataLightLevel');
}

// Filter Historical Data
function filterHistoricalData(sensorLogs) {
    const now = new Date();
    let cutoffDate;

    switch (currentFilter) {
        case '7d':
            cutoffDate = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
            break;
        case '30d':
            cutoffDate = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);
            break;
        case 'all':
        default:
            cutoffDate = new Date(0); // All time
            break;
    }

    const filtered = {};
    for (const [key, data] of Object.entries(sensorLogs)) {
        filtered[key] = data.filter(entry => new Date(entry.timestamp) >= cutoffDate);
    }

    return filtered;
}

// Render Individual Chart
function renderChart(canvasId, data, label, noDataId) {
    const canvas = document.getElementById(canvasId);
    const noDataElement = document.getElementById(noDataId);

    if (!data || data.length === 0) {
        canvas.style.display = 'none';
        noDataElement.classList.remove('hidden');
        return;
    }

    canvas.style.display = 'block';
    noDataElement.classList.add('hidden');

    // Destroy existing chart if it exists
    if (charts[canvasId]) {
        charts[canvasId].destroy();
    }

    const ctx = canvas.getContext('2d');

    charts[canvasId] = new Chart(ctx, {
        type: 'line',
        data: {
            labels: data.map(d => formatChartDate(new Date(d.timestamp))),
            datasets: [{
                label: label,
                data: data.map(d => d.value),
                borderColor: '#4CAF50',
                backgroundColor: 'rgba(76, 175, 80, 0.1)',
                borderWidth: 3,
                tension: 0.4,
                fill: true,
                pointBackgroundColor: '#4CAF50',
                pointBorderColor: '#fff',
                pointBorderWidth: 2,
                pointRadius: 4,
                pointHoverRadius: 6
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: true,
            plugins: {
                legend: {
                    display: false
                },
                tooltip: {
                    backgroundColor: 'rgba(46, 125, 50, 0.9)',
                    titleColor: '#fff',
                    bodyColor: '#fff',
                    padding: 12,
                    cornerRadius: 8
                }
            },
            scales: {
                x: {
                    display: true,
                    title: {
                        display: true,
                        text: 'Time',
                        color: '#2C3E50',
                        font: {
                            weight: 600
                        }
                    },
                    grid: {
                        color: 'rgba(0, 0, 0, 0.05)'
                    }
                },
                y: {
                    display: true,
                    title: {
                        display: true,
                        text: label,
                        color: '#2C3E50',
                        font: {
                            weight: 600
                        }
                    },
                    grid: {
                        color: 'rgba(0, 0, 0, 0.05)'
                    }
                }
            }
        }
    });
}

// Update Charts (when filter changes)
function updateCharts() {
    renderCharts();
}

// Update Time Filter UI
function updateTimeFilter(activeBtn) {
    document.querySelectorAll('.filter-btn').forEach(btn => {
        btn.classList.remove('active');
    });
    activeBtn.classList.add('active');
}

// ===== WATERING LOG =====
function renderWateringLog() {
    if (!plantData || !plantData.historicalData) return;

    const { wateringLogs } = plantData.historicalData;
    const listElement = document.getElementById('wateringLogList');
    const noDataElement = document.getElementById('noDataWateringLog');

    if (!wateringLogs || wateringLogs.length === 0) {
        listElement.innerHTML = '';
        noDataElement.classList.remove('hidden');
        return;
    }

    noDataElement.classList.add('hidden');

    listElement.innerHTML = wateringLogs.map(log => `
        <li>
            <span class="watering-timestamp">💧 ${formatDateTime(new Date(log.timestamp))}</span>
            <span class="watering-amount">Amount: ${log.amount}</span>
            ${log.notes ? `<span class="watering-notes">Notes: ${log.notes}</span>` : ''}
            <span class="watering-sensor-data">
                Soil Moisture: ${log.sensorDataAtWatering.soilMoisture}% |
                Temp: ${log.sensorDataAtWatering.airTemp}°C
            </span>
        </li>
    `).join('');
}

// ===== CARE SHEET =====
function renderCareSheet() {
    if (!plantData) return;

    const { llmCareSheet } = plantData;

    document.getElementById('careSheetTitle').textContent = llmCareSheet.title;
    document.getElementById('careSheetContent').textContent = llmCareSheet.content;
}

// ===== CONFIG FORM =====
function populateConfigForm() {
    if (!plantData) return;

    const { plant } = plantData;

    document.getElementById('inputPlantName').value = plant.name || '';
    document.getElementById('inputPlantNickname').value = plant.nickname || '';
    document.getElementById('inputPlantType').value = plant.type || '';
    document.getElementById('inputPlantAge').value = plant.age || '';
    document.getElementById('inputAgeUnit').value = plant.ageUnit || 'months';

    // Photo preview
    if (plant.photoUrl) {
        const preview = document.getElementById('photoPreview');
        preview.src = plant.photoUrl;
        preview.classList.remove('hidden');
    }
}

// Handle Photo Preview
function handlePhotoPreview(e) {
    const file = e.target.files[0];
    const preview = document.getElementById('photoPreview');

    if (!file) {
        preview.classList.add('hidden');
        return;
    }

    // Validate file size (5MB max)
    if (file.size > 5 * 1024 * 1024) {
        showFormError('Photo file too large — max 5MB');
        e.target.value = '';
        preview.classList.add('hidden');
        return;
    }

    // Validate file type
    if (!file.type.match('image/(jpeg|png)')) {
        showFormError('Only JPG or PNG images are allowed');
        e.target.value = '';
        preview.classList.add('hidden');
        return;
    }

    // Show preview
    const reader = new FileReader();
    reader.onload = (event) => {
        preview.src = event.target.result;
        preview.classList.remove('hidden');
    };
    reader.readAsDataURL(file);
}

// Handle Form Submit
async function handleFormSubmit(e) {
    e.preventDefault();

    hideFormMessages();

    // Validate required fields
    const plantName = document.getElementById('inputPlantName').value.trim();
    const plantType = document.getElementById('inputPlantType').value;

    if (!plantName) {
        showFormError('Plant name is required');
        return;
    }

    if (!plantType) {
        showFormError('Plant type is required');
        return;
    }

    // Collect form data
    const formData = {
        name: plantName,
        nickname: document.getElementById('inputPlantNickname').value.trim(),
        type: plantType === 'custom' ? document.getElementById('inputCustomPlantType').value.trim() : plantType,
        age: parseInt(document.getElementById('inputPlantAge').value) || null,
        ageUnit: document.getElementById('inputAgeUnit').value,
    };

    // Handle photo upload
    const photoFile = document.getElementById('inputPlantPhoto').files[0];
    if (photoFile) {
        formData.photo = photoFile;
    }

    try {
        if (USE_MOCK_DATA) {
            // Simulate API call
            await simulateConfigSave(formData);
        } else {
            // Real API call
            const response = await fetch(`${API_BASE_URL}/plant-config`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(formData)
            });

            if (!response.ok) {
                throw new Error('Failed to save plant configuration');
            }
        }

        showFormSuccess(`Plant details saved! LLM advice updated for your ${formData.name}. 🌿`);

        // Refresh data and return to home after 2 seconds
        setTimeout(async () => {
            await fetchPlantData(true); // Show spinner for user-initiated refresh
            showHomeScreen();
        }, 2000);

    } catch (error) {
        console.error('Error saving config:', error);
        showFormError('Failed to save plant details. Please try again.');
    }
}

// Simulate Config Save (for mock data mode)
async function simulateConfigSave(formData) {
    return new Promise((resolve) => {
        setTimeout(() => {
            // Update mock data
            if (plantData) {
                plantData.plant.name = formData.name;
                plantData.plant.nickname = formData.nickname;
                plantData.plant.type = formData.type;
                plantData.plant.age = formData.age;
                plantData.plant.ageUnit = formData.ageUnit;
            }
            resolve();
        }, 500);
    });
}

// ===== FORM MESSAGES =====
function showFormSuccess(message) {
    const element = document.getElementById('formSuccess');
    element.textContent = message;
    element.classList.remove('hidden');
}

function showFormError(message) {
    const element = document.getElementById('formError');
    element.textContent = message;
    element.classList.remove('hidden');
}

function hideFormMessages() {
    document.getElementById('formSuccess').classList.add('hidden');
    document.getElementById('formError').classList.add('hidden');
}

// ===== AUTO-REFRESH =====
function startAutoRefresh() {
    // Update countdown every second (smooth countdown)
    setInterval(() => {
        if (plantData && document.getElementById('homeScreen').classList.contains('active')) {
            updateCountdown();
        }
    }, 1000);

    // Refresh data every 10 seconds (smooth background updates without loading spinner)
    refreshInterval = setInterval(async () => {
        await fetchPlantData(false); // Don't show spinner on auto-refresh
    }, 10000);
}

// ===== LOADING & ERRORS =====
function showLoading(show) {
    const spinner = document.getElementById('loadingSpinner');
    if (show) {
        spinner.classList.remove('hidden');
    } else {
        spinner.classList.add('hidden');
    }
}

function showError(message) {
    alert(message); // Simple error display for MVP
}

// ===== UTILITY FUNCTIONS =====
function formatTimestamp(date) {
    const now = new Date();
    const diffMs = now - date;
    const diffMins = Math.floor(diffMs / 60000);

    if (diffMins < 1) {
        return 'Just now';
    } else if (diffMins < 60) {
        return `${diffMins} min${diffMins > 1 ? 's' : ''} ago`;
    } else if (diffMins < 1440) {
        const hours = Math.floor(diffMins / 60);
        return `${hours} hour${hours > 1 ? 's' : ''} ago`;
    } else {
        return formatDateTime(date);
    }
}

function formatDateTime(date) {
    const options = {
        month: 'short',
        day: 'numeric',
        hour: 'numeric',
        minute: '2-digit',
        hour12: true
    };
    return date.toLocaleString('en-US', options);
}

function formatChartDate(date) {
    const options = {
        month: 'short',
        day: 'numeric',
        hour: 'numeric',
        hour12: true
    };
    return date.toLocaleString('en-US', options);
}

function capitalizeFirst(str) {
    return str.charAt(0).toUpperCase() + str.slice(1);
}

function getPlantTypeEmoji(type) {
    const emojis = {
        'tropical': '🌴',
        'desert': '🌵',
        'fern': '🌿',
        'succulent': '🌵',
        'cactus': '🌵'
    };
    return emojis[type.toLowerCase()] || '🌱';
}
