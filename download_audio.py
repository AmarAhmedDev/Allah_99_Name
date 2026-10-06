#!/usr/bin/env python3
"""
Download all 99 beautiful recitations of Allah's names
This script downloads audio files from multiple sources with fallback
"""

import os
import requests
from pathlib import Path
import time

# Create assets/audio directory if it doesn't exist
audio_dir = Path("assets/audio")
audio_dir.mkdir(parents=True, exist_ok=True)

# Audio sources (in order of preference)
SOURCES = [
    {
        "name": "Islamic Finder",
        "url_template": "https://www.islamicfinder.us/audios/asma-ul-husna/{:03d}.mp3",
        "format": "padded"  # 001, 002, etc.
    },
    {
        "name": "GitHub Repository",
        "url_template": "https://raw.githubusercontent.com/soachishti/Asma-ul-Husna/master/audio/{}.mp3",
        "format": "normal"  # 1, 2, etc.
    },
    {
        "name": "Islamic Network",
        "url_template": "https://cdn.islamic.network/quran/audio/128/ar.alafasy/{}.mp3",
        "format": "normal"
    }
]

def download_file(url, filepath):
    """Download a file from URL to filepath"""
    try:
        print(f"  Trying: {url}")
        response = requests.get(url, timeout=30, stream=True)
        response.raise_for_status()
        
        with open(filepath, 'wb') as f:
            for chunk in response.iter_content(chunk_size=8192):
                f.write(chunk)
        
        file_size = os.path.getsize(filepath)
        if file_size < 1000:  # Less than 1KB is probably an error
            os.remove(filepath)
            return False
            
        print(f"  ✓ Downloaded ({file_size:,} bytes)")
        return True
    except Exception as e:
        print(f"  ✗ Failed: {e}")
        if os.path.exists(filepath):
            os.remove(filepath)
        return False

def download_all_audio():
    """Download all 99 audio files"""
    print("=" * 60)
    print("Downloading Beautiful Recitations of Allah's 99 Names")
    print("=" * 60)
    
    successful = 0
    failed = []
    
    for i in range(1, 100):
        filename = f"{i:03d}.mp3"
        filepath = audio_dir / filename
        
        # Skip if already exists
        if filepath.exists() and os.path.getsize(filepath) > 1000:
            print(f"\n[{i}/99] {filename} - Already exists ✓")
            successful += 1
            continue
        
        print(f"\n[{i}/99] Downloading {filename}...")
        
        # Try each source until one succeeds
        downloaded = False
        for source in SOURCES:
            if source["format"] == "padded":
                url = source["url_template"].format(i)
            else:
                url = source["url_template"].format(i)
            
            print(f"  Source: {source['name']}")
            if download_file(url, filepath):
                downloaded = True
                successful += 1
                break
            
            time.sleep(0.5)  # Small delay between attempts
        
        if not downloaded:
            failed.append(i)
            print(f"  ✗ All sources failed for {filename}")
        
        # Small delay between files to be respectful to servers
        time.sleep(0.3)
    
    # Summary
    print("\n" + "=" * 60)
    print("DOWNLOAD SUMMARY")
    print("=" * 60)
    print(f"✓ Successful: {successful}/99")
    print(f"✗ Failed: {len(failed)}/99")
    
    if failed:
        print(f"\nFailed files: {', '.join(map(str, failed))}")
        print("\nYou can try running the script again for failed files.")
    else:
        print("\n🎉 All audio files downloaded successfully!")
        print(f"📁 Location: {audio_dir.absolute()}")
    
    return successful, failed

if __name__ == "__main__":
    try:
        print("\nInstalling required package...")
        os.system("pip install requests")
        print("\nStarting download...\n")
        download_all_audio()
    except KeyboardInterrupt:
        print("\n\n⚠️  Download interrupted by user")
    except Exception as e:
        print(f"\n\n❌ Error: {e}")
