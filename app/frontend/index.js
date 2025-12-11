// Age

function age() {
  var today = new Date();
  var birthday = new Date('2001-10-25');
  var age = today.getFullYear() - birthday.getFullYear();
  var m = today.getMonth() - birthday.getMonth();
  if (m < 0 || (m === 0 && today.getDate() < birthday.getDate())) age--;
  return age;
}

document.getElementById('age').textContent = age();

// Contributions

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
const LOW_COLOR = { r: 231, g: 237, b: 227 }
const HIGH_COLOR = { r: 83, g: 217, b: 156 }

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

function fakeContributions() {
  let contrib = new Array(52); // 52 weeks
  for (let w = 0; w < contrib.length; w++) {
    contrib[w] = new Array(7);
    let week = contrib[w];
    for (let d = 0; d < week.length; d++) {
      week[d] = Math.floor(Math.pow(Math.random(), 2) * 21);
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
  } catch (error) {
    console.error("Failed to fetch contributions:", error);
    return fakeContributions();
  }
}

const BOX_SIZE = 40;
function createBox(x, y, color) {
  const box = document.createElementNS("http://www.w3.org/2000/svg", "rect");
  box.setAttribute("x", x);
  box.setAttribute("y", y);
  box.setAttribute("width", BOX_SIZE);
  box.setAttribute("height", BOX_SIZE);
  box.setAttribute("fill", color);
  return box;
}

function createContribGraph(contribs) {
  const width = contribs.length * BOX_SIZE;
  const height = 7 * BOX_SIZE;

  const graph = document.createElementNS("http://www.w3.org/2000/svg", "svg");
  graph.style.height = "100%";
  graph.setAttribute("viewBox", `0 0 ${width} ${height}`);

  let max = maxCount(contribs);

  for (let w = 0; w < contribs.length; w++) {
    let week = contribs[w];
    for (let d = 0; d < week.length; d++) {
      let count = week[d];
      let color = getColor(count, max);
      let box = createBox(w * BOX_SIZE, d * BOX_SIZE, color);
      graph.appendChild(box);
    }
  }
  return graph;
}

async function initContributions() {
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

// Commit Hash

async function fetchCommit() {
  try {
    const response = await fetch('/api/commit');
    if (!response.ok) {
      throw new Error(`API error: ${response.status}`);
    }

    const data = await response.json();
    return data.commit;
  } catch (error) {
    console.error("Failed to fetch commit hash:", error);
    return "SHRTREV"
  }
}

const GITHUB_OWNER = "cpwrs"
const GITHUB_REPO = "carsonp.net"
function commitToLink(hash) {
  return `https://github.com/${GITHUB_OWNER}/${GITHUB_REPO}/tree/${hash}`;
}

async function initCommit() {
  const commitLink = document.getElementById("commit");
  try {
    const commit = await fetchCommit();
    const link = commitToLink(commit);
    commitLink.href = `${link}`
    commitLink.textContent = `${commit}`;
  } catch (error) {
    console.error("Failed to set status:", error);
  }
}

document.getElementById('age').textContent = age();
initContributions();
initCommit();
