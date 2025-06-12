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

const NO_COLOR = { r: 240, g: 238, b: 231 }
const LOW_COLOR = { r: 228, g: 241, b: 228 }
const HIGH_COLOR = { r: 137, g: 255, b: 203 }

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

// Create an empty contributions array
function emptyContributions() {
  let contrib = new Array(52); // 52 weeks
  for (let w = 0; w < contrib.length; w++) {
    contrib[w] = new Array(7);
    let week = contrib[w];
    for (let d = 0; d < week.length; d++) {
      week[d] = 0;
    }
  }

  return contrib;
}

// Fetch GitHub contributions from API 
async function fetchContributions() {
  try {
    const response = await fetch('/api/contributions')

    if (!response.ok) {
      throw new Error(`API error: ${response.status}`);
    }

    const data = await response.json();
    const contributions = data.data.user.contributionsCollection.contributionCalendar;

    return contributions.weeks.map(week =>
      week.contributionDays.map(day => day.contributionCount)
    );
  } catch(error) {
    console.error("Failed to fetch contributions:", error);
    return emptyContributions();
  }
}

const BOX_SIZE = 40;
const BOX_GAP = 8;
const CORNER_RADIUS = 5;
const STROKE_COLOR = "#e3e1d7";
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
  box.setAttribute("rx", CORNER_RADIUS);
  box.setAttribute("ry", CORNER_RADIUS);
  box.setAttribute("stroke", STROKE_COLOR);
  box.setAttribute("stroke-width", STROKE_WIDTH);

  return box;
}

// Create a whole graph of contribution boxes
function createContribGraph(contribs) {
  const width = contribs.length * GRAPH_CELL + BOX_GAP;
  const height = 7 * GRAPH_CELL + BOX_GAP;

  const graph = document.createElementNS("http://www.w3.org/2000/svg", "svg");
  graph.style.height = "100%";
  graph.setAttribute("viewBox", `0 0 ${width} ${height}`);

  let max = maxCount(contribs);

  for (let w = 0; w < contribs.length; w++) {
    let week = contribs[w];
    for (let d = 0; d < week.length; d++) {
      let count = week[d];
      let color = getColor(count, max);
      let box = createBox(w * GRAPH_CELL + BOX_GAP, d * GRAPH_CELL + BOX_GAP, color);
      graph.appendChild(box);
    }
  }

  return graph;
}

async function init() {
  const container = document.getElementById("contributions");
  try {
    const contributions = await fetchContributions();

    // Create two graphs, for a rotating carousel effect
    const graph = createContribGraph(contributions);
    const clone = graph.cloneNode(true);
    clone.setAttribute("aria-hidden", true);

    container.appendChild(graph);
    container.appendChild(clone);
  } catch (error) {
    if (container) container.remove();
    console.error("Failed to create the contributions graph:", error);
  }
}

init();
