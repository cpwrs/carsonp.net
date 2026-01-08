import { env } from '$env/dynamic/private';
import type { LayoutServerLoad } from './$types';

const GITHUB_USERNAME = 'cpwrs';
const QUERY = `
  query($userName:String!) {
    user(login: $userName){
      contributionsCollection {
        contributionCalendar {
          totalContributions
          weeks {
            contributionDays {
              contributionCount
              date
            }
          }
        }
      }
    }
  }
`;

async function fetchGitHubContributions() {
  const response = await fetch('https://api.github.com/graphql', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${env.GITHUB_TOKEN}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      query: QUERY,
      variables: { userName: GITHUB_USERNAME }
    })
  });

  const data = await response.json();
  const calendar = data.data.user.contributionsCollection.contributionCalendar;
  const contributions = calendar.weeks.map((week: any) =>
    week.contributionDays.map((day: any) => day.contributionCount),
  );

  return contributions;
}

function fakeContributions(): number[][] {
  let contrib = new Array(52); // 52 weeks
  for (let w = 0; w < contrib.length; w++) {
    contrib[w] = new Array(7);
    let week = contrib[w];
    for (let d = 0; d < week.length; d++) {
      week[d] = Math.floor(Math.pow(Math.random(), 8) * 21);
    }
  }
  return contrib;
}

export const load: LayoutServerLoad = () => {
  const prod = env.PROD === '1';
  return {
    contributions: prod
      ? (env.GITHUB_TOKEN ? fetchGitHubContributions() : null)
      : fakeContributions(),
  }
};
