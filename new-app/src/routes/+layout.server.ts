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

export const load: LayoutServerLoad = () => {
  return {
    contributions: env.GITHUB_TOKEN ? fetchGitHubContributions() : null,
    prod: env.PROD === '1',
  }
};
