// Fetch and display the app status (Production? Commit hash?)

async function fetchStatus() {
  const response = await fetch('/api/status');
  if (!response.ok) {
    throw new Error(`API error: ${response.status}`);
  }

  const data = await response.json();
  return data;
}

const GITHUB_OWNER = "cpwrs"
const GITHUB_REPO = "carsonp.net"
function commitToLink(hash) {
  return `https://github.com/${GITHUB_OWNER}/${GITHUB_REPO}/tree/${hash}`;
}

async function init() {
  const prod_tag = document.getElementById("prod-tag");
  const build_tag = document.getElementById("build-tag");

  try {
    const status = await fetchStatus();

    // If in dev env
    if (status === false) {
      prod_tag.innerHTML = "DEV";
      if (build_tag) build_tag.remove();
      return;
    }

    // If in prod env
    if (status && status.commit) {
      prod_tag.innerHTML = "PROD";
      const link = commitToLink(status.commit);
      build_tag.innerHTML = `BUILD <a href="${link}" id="build-link">${status.commit}</a>`;
      return
    }

    // Bad status
    throw new Error("Unexpected data format from /api/status: " + JSON.stringify(status));
  } catch(error) {
    // Show an failed status on the status bar
    prod_tag.innerHTML = "API FAIL";
    prod_tag.style.background = "#ff5766";
    if (build_tag) build_tag.remove();

    console.error("Failed to set status: ", error);
  }
}

init();
