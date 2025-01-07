from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
import httpx
import os

app = FastAPI()

# Constants for GitHub contributions GraphQL API
GITHUB_TOKEN = os.environ["GITHUB_TOKEN"]
GITHUB_USERNAME = "cpwrs"
QUERY = """
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
"""

# Endpoint to retrieve my contributions
@app.get("/api/contrubtions")
async def get_contributions():
  async with httpx.AsyncClient() as client:
    response = await client.post(
      "https://api.github.com/graphql",
      headers = {
        "Authorization": f"Bearer {GITHUB_TOKEN}",
        "Content-Type": "application/json",
      },
      json = {
        "query": QUERY,
        "variables": { "userName": GITHUB_USERNAME },
      },
    )
    return response.json()

# Serve the website frontend
app.mount("/", StaticFiles(directory="frontend", html=True), name="frontend")
