import pytest
import responses
import os
import zipfile
from unittest.mock import patch, MagicMock
from io import BytesIO

# Import functions from the script
from download_latest_version import (
    get_latest_version_url,
    extract_version_from_url,
    download_and_extract,
    MOJANG_API_URL
)

@responses.activate
def test_get_latest_version_url_success():
    mock_response = {
        "result": {
            "links": [
                {"downloadType": "serverBedrockWindows", "downloadUrl": "https://example.com/win.zip"},
                {"downloadType": "serverBedrockLinux", "downloadUrl": "https://www.minecraft.net/bedrockdedicatedserver/bin-linux/bedrock-server-1.20.10.zip"}
            ]
        }
    }
    responses.add(responses.GET, MOJANG_API_URL, json=mock_response, status=200)
    
    url = get_latest_version_url()
    assert url == "https://www.minecraft.net/bedrockdedicatedserver/bin-linux/bedrock-server-1.20.10.zip"

@responses.activate
def test_get_latest_version_url_missing_linux():
    mock_response = {
        "result": {
            "links": [
                {"downloadType": "serverBedrockWindows", "downloadUrl": "https://example.com/win.zip"}
            ]
        }
    }
    responses.add(responses.GET, MOJANG_API_URL, json=mock_response, status=200)
    
    with pytest.raises(SystemExit):
        get_latest_version_url()

@responses.activate
def test_get_latest_version_url_api_error():
    responses.add(responses.GET, MOJANG_API_URL, status=500)
    
    with pytest.raises(SystemExit):
        get_latest_version_url()

def test_extract_version_from_url():
    url = "https://www.minecraft.net/bedrockdedicatedserver/bin-linux/bedrock-server-1.26.20.5.zip"
    version = extract_version_from_url(url)
    assert version == "1.26.20.5"

def test_extract_version_from_url_invalid():
    url = "https://www.minecraft.net/invalid-url.zip"
    with pytest.raises(SystemExit):
        extract_version_from_url(url)

@responses.activate
def test_download_and_extract(tmp_path):
    # Create a valid in-memory zip file
    zip_buffer = BytesIO()
    with zipfile.ZipFile(zip_buffer, "a", zipfile.ZIP_DEFLATED, False) as zip_file:
        zip_file.writestr("test_file.txt", "Hello World")
    
    zip_content = zip_buffer.getvalue()
    
    url = "https://example.com/test.zip"
    responses.add(responses.GET, url, body=zip_content, status=200)
    
    # Run the function using the tmp_path as the destination
    download_and_extract(url, str(tmp_path))
    
    # Assert extraction was successful and cleanup occurred
    extracted_file_path = tmp_path / "test_file.txt"
    assert extracted_file_path.exists()
    assert extracted_file_path.read_text() == "Hello World"
    
    zip_path = tmp_path / "bedrock-server.zip"
    assert not zip_path.exists()

@responses.activate
def test_download_and_extract_download_error(tmp_path):
    url = "https://example.com/test.zip"
    responses.add(responses.GET, url, status=404)
    
    with pytest.raises(SystemExit):
        download_and_extract(url, str(tmp_path))

@responses.activate
def test_download_and_extract_unzip_error(tmp_path):
    # Mocking a corrupted zip file
    url = "https://example.com/test.zip"
    responses.add(responses.GET, url, body=b"Not a zip file", status=200)
    
    with pytest.raises(SystemExit):
        download_and_extract(url, str(tmp_path))
    
    # Ensure zip file is still cleaned up even if extraction fails
    zip_path = tmp_path / "bedrock-server.zip"
    assert not zip_path.exists()
