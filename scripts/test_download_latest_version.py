import unittest
from unittest.mock import patch, MagicMock
import os
import zipfile
import tempfile
import shutil
from io import BytesIO

# Import functions from the script
from download_latest_version import (
    get_latest_version_url,
    extract_version_from_url,
    download_and_extract,
    MOJANG_API_URL
)

class TestDownloadLatestVersion(unittest.TestCase):

    @patch('urllib.request.urlopen')
    def test_get_latest_version_url_success(self, mock_urlopen):
        mock_response = MagicMock()
        mock_response.read.return_value = b'''
        {
            "result": {
                "links": [
                    {"downloadType": "serverBedrockWindows", "downloadUrl": "https://example.com/win.zip"},
                    {"downloadType": "serverBedrockLinux", "downloadUrl": "https://www.minecraft.net/bedrockdedicatedserver/bin-linux/bedrock-server-1.20.10.zip"}
                ]
            }
        }
        '''
        mock_response.__enter__.return_value = mock_response
        mock_urlopen.return_value = mock_response
        
        url = get_latest_version_url()
        self.assertEqual(url, "https://www.minecraft.net/bedrockdedicatedserver/bin-linux/bedrock-server-1.20.10.zip")

    @patch('urllib.request.urlopen')
    def test_get_latest_version_url_missing_linux(self, mock_urlopen):
        mock_response = MagicMock()
        mock_response.read.return_value = b'''
        {
            "result": {
                "links": [
                    {"downloadType": "serverBedrockWindows", "downloadUrl": "https://example.com/win.zip"}
                ]
            }
        }
        '''
        mock_response.__enter__.return_value = mock_response
        mock_urlopen.return_value = mock_response
        
        with self.assertRaises(SystemExit):
            get_latest_version_url()

    @patch('urllib.request.urlopen')
    def test_get_latest_version_url_api_error(self, mock_urlopen):
        import urllib.error
        mock_urlopen.side_effect = urllib.error.URLError("Server Error")
        
        with self.assertRaises(SystemExit):
            get_latest_version_url()

    def test_extract_version_from_url(self):
        url = "https://www.minecraft.net/bedrockdedicatedserver/bin-linux/bedrock-server-1.26.20.5.zip"
        version = extract_version_from_url(url)
        self.assertEqual(version, "1.26.20.5")

    def test_extract_version_from_url_invalid(self):
        url = "https://www.minecraft.net/invalid-url.zip"
        with self.assertRaises(SystemExit):
            extract_version_from_url(url)

    @patch('urllib.request.urlopen')
    def test_download_and_extract(self, mock_urlopen):
        # Create a valid in-memory zip file
        zip_buffer = BytesIO()
        with zipfile.ZipFile(zip_buffer, "a", zipfile.ZIP_DEFLATED, False) as zip_file:
            zip_file.writestr("test_file.txt", "Hello World")
        zip_content = zip_buffer.getvalue()
        
        # Mock the chunked reading
        mock_response = MagicMock()
        mock_response.read.side_effect = [zip_content, b""] # Return content then EOF
        mock_response.__enter__.return_value = mock_response
        mock_urlopen.return_value = mock_response
        
        url = "https://example.com/test.zip"
        tmp_dir = tempfile.mkdtemp()
        
        try:
            # Run the function using the tmp_dir as the destination
            download_and_extract(url, tmp_dir)
            
            # Assert extraction was successful and cleanup occurred
            extracted_file_path = os.path.join(tmp_dir, "test_file.txt")
            self.assertTrue(os.path.exists(extracted_file_path))
            with open(extracted_file_path, 'r') as f:
                self.assertEqual(f.read(), "Hello World")
            
            zip_path = os.path.join(tmp_dir, "bedrock-server.zip")
            self.assertFalse(os.path.exists(zip_path))
        finally:
            shutil.rmtree(tmp_dir)

    @patch('urllib.request.urlopen')
    def test_download_and_extract_download_error(self, mock_urlopen):
        import urllib.error
        mock_urlopen.side_effect = urllib.error.HTTPError(
            "https://example.com/test.zip", 404, "Not Found", {}, None
        )
        
        url = "https://example.com/test.zip"
        tmp_dir = tempfile.mkdtemp()
        
        try:
            with self.assertRaises(SystemExit):
                download_and_extract(url, tmp_dir)
        finally:
            shutil.rmtree(tmp_dir)

    @patch('urllib.request.urlopen')
    def test_download_and_extract_unzip_error(self, mock_urlopen):
        # Mocking a corrupted zip file
        mock_response = MagicMock()
        mock_response.read.side_effect = [b"Not a zip file", b""] # Return content then EOF
        mock_response.__enter__.return_value = mock_response
        mock_urlopen.return_value = mock_response
        
        url = "https://example.com/test.zip"
        tmp_dir = tempfile.mkdtemp()
        
        try:
            with self.assertRaises(SystemExit):
                download_and_extract(url, tmp_dir)
            
            # Ensure zip file is still cleaned up even if extraction fails
            zip_path = os.path.join(tmp_dir, "bedrock-server.zip")
            self.assertFalse(os.path.exists(zip_path))
        finally:
            shutil.rmtree(tmp_dir)

if __name__ == '__main__':
    unittest.main()
