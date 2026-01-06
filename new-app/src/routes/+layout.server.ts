import { env } from '$env/dynamic/private';
import type { LayoutServerLoad } from './$types';

const GITHUB_USERNAME = 'cpwrs';
const GITHUB_TOKEN = env.GITHUB_TOKEN;

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

export const load: LayoutServerLoad = async () => {
  if (!GITHUB_TOKEN) {
    console.error('GitHub token not available');
    return {
      contributions: null
    };
  }

  try {
    const response = await fetch('https://api.github.com/graphql', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${GITHUB_TOKEN}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        query: QUERY,
        variables: { userName: GITHUB_USERNAME }
      })
    });

    if (!response.ok) {
      console.error(`GitHub API error: ${response.status}`);
      return {
        contributions: null
      };
    }

    const data = await response.json();
    const calendar = data.data.user.contributionsCollection.contributionCalendar;

    // Convert to number[][] format
    const contributions = calendar.weeks.map((week: any) =>
      week.contributionDays.map((day: any) => day.contributionCount)
    );

    return {
      contributions
    };
  } catch (err) {
    console.error('Failed to fetch contributions:', err);
    return {
      contributions: null
    };
  }
};
