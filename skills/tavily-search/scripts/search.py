#!/usr/bin/env python3
"""
Tavily Web Search Script for OpenClaw
Uses Tavily API to perform web searches
"""

import sys
import json
import urllib.request
import urllib.parse
import re

def get_api_key():
    """Extract Tavily API key from OpenClaw config"""
    try:
        with open(f"{__import__('os').path.expanduser('~')}/.openclaw/openclaw.json", 'r') as f:
            config = json.load(f)
            # Try skills.entries.web-search.apiKey first
            api_key = config.get('skills', {}).get('entries', {}).get('web-search', {}).get('apiKey', '')
            if api_key:
                return api_key
            # Fallback: try mcpServers.tavily.url
            tavily_url = config.get('mcpServers', {}).get('tavily', {}).get('url', '')
            match = re.search(r'tavilyApiKey=([^&]+)', tavily_url)
            if match:
                return match.group(1)
    except Exception as e:
        print(f"Error reading config: {e}", file=sys.stderr)
    return None

def search(query, num_results=5):
    """Perform Tavily search"""
    api_key = get_api_key()
    if not api_key:
        return {"error": "Could not find Tavily API key. Please add it to ~/.openclaw/openclaw.json under skills.entries.web-search.apiKey"}
    
    url = "https://api.tavily.com/search"
    headers = {"Content-Type": "application/json"}
    data = {
        "api_key": api_key,
        "query": query,
        "search_depth": "basic",
        "include_answer": False,
        "max_results": num_results
    }
    
    try:
        req = urllib.request.Request(
            url,
            data=json.dumps(data).encode('utf-8'),
            headers=headers,
            method='POST'
        )
        with urllib.request.urlopen(req, timeout=30) as response:
            result = json.loads(response.read().decode('utf-8'))
            return result
    except Exception as e:
        return {"error": f"Search failed: {str(e)}"}

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 search.py <query>", file=sys.stderr)
        sys.exit(1)
    
    query = " ".join(sys.argv[1:])
    results = search(query)
    print(json.dumps(results, indent=2, ensure_ascii=False))
