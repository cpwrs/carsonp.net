// Fetch GitHub contributions from my FastAPI
async function fetchContributions() {
  try {
    const response = await fetch('/api/contributions')
    const data = await response.json();
    const contributions = data.data.user.contributionsCollection.contributionCalendar;

    document.getElementById('contributions').innerHTML = `
      <h2>Total Contributions: ${contributions.totalContributions}</h2>
      <div class="calendar">
        ${contributions.weeks.map(week =>
          week.contributionDays.map(day =>
            `<div class="day" data-count="${day.contributionCount}">
              ${day.date}: ${day.contributionCount}
            </div>`
          ).join('')
        ).join('')}
      </div>
    `;
  } catch (error) {
    console.error('Error:', error);
  }
}

fetchContributions()
