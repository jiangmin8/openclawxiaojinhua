---
name: tavily-search
description: Web search using Tavily API. Use when the user needs to search the internet for information, news, research, or any online content. Alternative to web_search tool when Brave API is not available.
---

# Tavily Web Search

Use this skill to perform web searches using Tavily API.

## Usage

```bash
python3 ~/.openclaw/workspace/skills/tavily-search/scripts/search.py "your search query"
```

## API Key

The skill reads your Tavily API key from OpenClaw config (`~/.openclaw/openclaw.json`) under `skills.entries.web-search.apiKey`.

## Output Format

Returns JSON with search results including title, URL, and content snippet.
