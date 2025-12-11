from fastapi import FastAPI, HTTPException
from fastapi.staticfiles import StaticFiles
from pathlib import Path
from argparse import ArgumentParser
import uvicorn
import httpx
import os

app = FastAPI()

# Environment variables
GITHUB_TOKEN = os.environ.get("GITHUB_TOKEN")
COMMIT = os.environ.get("COMMIT")

# For GitHub GraphQL request
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

# Retrieve GitHub contribution data
@app.get("/api/contributions")
async def get_contributions():
  if not GITHUB_TOKEN:
    raise HTTPException(status_code=500, detail="GitHub contributions not available")
  try:
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
  except httpx.HTTPStatusError as e:
    raise HTTPException(status_code=e.response.status_code, detail=str(e))

# Retrieve the commit rev
@app.get("/api/commit")
def get_commit():
  if not COMMIT:
    raise HTTPException(status_code=500, detail="Commit not available")
  return { "commit": COMMIT }


# Serve the frontend
APP = Path(__file__).parent
FRONTEND = APP / "frontend"
app.mount("/", StaticFiles(directory=FRONTEND, html=True), name="frontend")

if __name__ == "__main__":
  # CLI arguments for port and host
  p = ArgumentParser(description="Start the backend server with a custom host and port")
  p.add_argument("--port", type=int, default=8000, help="Port to run the server on (defaults to 8000)")
  p.add_argument("--host", type=str, default="127.0.0.1", help="Host to run the server on (defaults to loopback)")
  args = p.parse_args()

  uvicorn.run(
      "backend:app", 
      port=args.port, 
      host=args.host
      )
