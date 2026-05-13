#!/usr/bin/env python3

import argparse
import sys
import os
import requests
import zipfile
import re

MOJANG_API_URL = "https://net-secondary.web.minecraft-services.net/api/v1.0/download/links"

def get_latest_version_url():
    """Fetches the latest Minecraft Bedrock Dedicated Server URL for Linux from the Mojang API."""
    try:
        headers = {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/93.0.4577.63 Safari/537.36"}
        response = requests.get(MOJANG_API_URL, headers=headers, timeout=10)
        response.raise_for_status()
        data = response.json()
        
        for link_info in data.get("result", {}).get("links", []):
            if link_info.get("downloadType") == "serverBedrockLinux":
                return link_info.get("downloadUrl")
        
        print("Error: Could not find 'serverBedrockLinux' download type in the API response.", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"Error fetching latest version from API: {e}", file=sys.stderr)
        sys.exit(1)

def extract_version_from_url(url):
    """Extracts the version string from the download URL."""
    match = re.search(r'bedrock-server-([0-9\.]+)\.zip', url)
    if match:
        return match.group(1)
    print(f"Error: Could not extract version from URL: {url}", file=sys.stderr)
    sys.exit(1)

def download_and_extract(url, dest_dir):
    """Downloads the zip file from the URL and extracts it to the destination directory."""
    zip_path = os.path.join(dest_dir, "bedrock-server.zip")
    
    print(f"Downloading {url}...", file=sys.stderr)
    try:
        headers = {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/93.0.4577.63 Safari/537.36"}
        response = requests.get(url, stream=True, headers=headers, timeout=120)
        response.raise_for_status()
        with open(zip_path, 'wb') as f:
            for chunk in response.iter_content(chunk_size=8192):
                f.write(chunk)
    except Exception as e:
        print(f"Error downloading the server: {e}", file=sys.stderr)
        sys.exit(1)
        
    print(f"Extracting to {dest_dir}...", file=sys.stderr)
    try:
        with zipfile.ZipFile(zip_path, 'r') as zip_ref:
            zip_ref.extractall(dest_dir)
    except Exception as e:
        print(f"Error extracting the zip file: {e}", file=sys.stderr)
        sys.exit(1)
    finally:
        if os.path.exists(zip_path):
            os.remove(zip_path)

def main():
    parser = argparse.ArgumentParser(description="Download Minecraft Bedrock Dedicated Server")
    parser.add_argument("--dest", type=str, default=".", help="Destination directory for the server files")
    parser.add_argument("--version", type=str, default="", help="Optional fixed version to download")
    parser.add_argument("--get-version-only", action="store_true", help="Only print the version string without downloading")
    
    args = parser.parse_args()
    dest_dir = os.path.abspath(args.dest)
    
    if not args.get_version_only and not os.path.exists(dest_dir):
        os.makedirs(dest_dir, exist_ok=True)
        
    if args.version:
        version = args.version
        if not args.get_version_only:
            print(f"Using provided version: {version}", file=sys.stderr)
        url = f"https://www.minecraft.net/bedrockdedicatedserver/bin-linux/bedrock-server-{version}.zip"
    else:
        if not args.get_version_only:
            print("Fetching latest version from Mojang API...", file=sys.stderr)
        url = get_latest_version_url()
        version = extract_version_from_url(url)
        if not args.get_version_only:
            print(f"Latest version found: {version}", file=sys.stderr)
        
    if not args.get_version_only:
        download_and_extract(url, dest_dir)
    
    # Print exactly the version to stdout for capturing
    print(version)

if __name__ == "__main__":
    main()
