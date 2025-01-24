// Create a graph of my GitHub contributions using the API

// Get the max number of contributions in the last year
function maxCount(contribs) {
  let max = 0;
  for (let w = 0; w < contribs.length; w++) {
    let week = contribs[w];
    for (let d = 0; d < week.length; d++) {
      let count = week[d];
      if (count > max) { max = count };
    }
  }

  return max;
}

const NO_COLOR = { r: 255, g: 252, b: 246 }
const LOW_COLOR = { r: 230, g: 250, b: 234 }
const HIGH_COLOR = { r: 33, g: 110, b: 57 }

// Interpolate a color between LOW and HIGH based on one days contrib count, and the yearly max
function getColor(count, max) {
  if (count === 0) {  
    return `rgb(${NO_COLOR.r}, ${NO_COLOR.g}, ${NO_COLOR.b})` 
  }

  const percent = count / max;
  const r = Math.round(LOW_COLOR.r + (HIGH_COLOR.r - LOW_COLOR.r) * percent);
  const g = Math.round(LOW_COLOR.g + (HIGH_COLOR.g - LOW_COLOR.g) * percent);
  const b = Math.round(LOW_COLOR.b + (HIGH_COLOR.b - LOW_COLOR.b) * percent);
  return `rgb(${r}, ${g}, ${b})`;
}

// Fetch GitHub contributions from API 
async function fetchContributions() {
  try {
    const response = await fetch('/api/contributions')
    const data = await response.json();
    const contributions = data.data.user.contributionsCollection.contributionCalendar;

    return contributions.weeks.map(week =>
      week.contributionDays.map(day => day.contributionCount)
    );
  } catch (error) {
    throw error;
  }
}

const BOX_SIZE = 40;
const BOX_GAP = 0;
const CORNER_RADIUS = 2;
const STROKE_COLOR = "#e0e0e0";
const STROKE_WIDTH = 1;
const GRAPH_CELL = BOX_SIZE + BOX_GAP;

// Create svg box for a day of contributions
function createBox(x, y, color) {
  const box = document.createElementNS("http://www.w3.org/2000/svg", "rect");
  box.setAttribute("x", x);
  box.setAttribute("y", y);
  box.setAttribute("width", BOX_SIZE);
  box.setAttribute("height", BOX_SIZE);
  box.setAttribute("fill", color);
  // box.setAttribute("rx", CORNER_RADIUS);
  // box.setAttribute("ry", CORNER_RADIUS);
  // box.setAttribute("stroke", STROKE_COLOR);
  // box.setAttribute("stroke-width", STROKE_WIDTH);

  return box;
}

// Create a whole graph of contribution boxes
function createContribGraph(contribs) {
  const width = contribs.length * GRAPH_CELL;
  const height = 7 * GRAPH_CELL;

  const graph = document.createElementNS("http://www.w3.org/2000/svg", "svg");
  graph.style.height = "100%";
  graph.setAttribute("viewBox", `0 0 ${width} ${height}`);

  let max = maxCount(contribs);

  for (let w = 0; w < contribs.length; w++) {
    let week = contribs[w];
    for (let d = 0; d < week.length; d++) {
      let count = week[d];
      let color = getColor(count, max);
      let box = createBox(w * GRAPH_CELL, d * GRAPH_CELL, color);
      graph.appendChild(box);
    }
  }

  return graph;
}

async function init() {
  try {
    const contributions = await fetchContributions();
    const contribDiv = document.getElementById("contributions");

    // Create two graphs, for a rotating carousel effect
    const graph = createContribGraph(contributions);
    const clone = graph.cloneNode(true);
    const container = document.getElementById('contributions');

    contribDiv.appendChild(graph);
    // Second one should be hidden for now
    clone.setAttribute("aria-hidden", true);
    contribDiv.appendChild(clone);
  } catch (error) {
    console.error("Failed to create the contributions graph:", error);
  }
}

init();
