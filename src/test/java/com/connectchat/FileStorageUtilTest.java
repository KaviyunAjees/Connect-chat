package com.connectchat;

import com.connectchat.util.FileStorageUtil;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

public class FileStorageUtilTest {

    @Test
    public void testFileExtensionExtraction() {
        assertEquals("pdf", FileStorageUtil.getExtension("document.pdf"));
        assertEquals("png", FileStorageUtil.getExtension("IMAGE.PNG"));
        assertEquals("docx", FileStorageUtil.getExtension("my.contract.final.docx"));
        assertEquals("", FileStorageUtil.getExtension("noextension"));
        assertEquals("", FileStorageUtil.getExtension(null));
    }

    @Test
    public void testFilenameSanitization() {
        assertEquals("report.pdf", FileStorageUtil.sanitizeFileName("report.pdf"));
        // Path traversal sanitization
        String sanitized = FileStorageUtil.sanitizeFileName("../../etc/passwd");
        assertFalse(sanitized.contains("/"));
        assertFalse(sanitized.contains("\\"));
        assertFalse(sanitized.contains(".."));

        String winSanitized = FileStorageUtil.sanitizeFileName("..\\..\\windows\\system32\\calc.exe");
        assertFalse(winSanitized.contains("\\"));
        assertFalse(winSanitized.contains(".."));
    }

    @Test
    public void testForbiddenExtensions() {
        assertTrue(FileStorageUtil.isForbidden("malicious.exe"));
        assertTrue(FileStorageUtil.isForbidden("shell.jsp"));
        assertTrue(FileStorageUtil.isForbidden("exploit.jspx"));
        assertTrue(FileStorageUtil.isForbidden("script.bat"));
        assertTrue(FileStorageUtil.isForbidden("run.sh"));
        assertTrue(FileStorageUtil.isForbidden("archive.war"));
        assertTrue(FileStorageUtil.isForbidden("attack.php"));
        assertTrue(FileStorageUtil.isForbidden("hack.js"));

        assertFalse(FileStorageUtil.isForbidden("document.pdf"));
        assertFalse(FileStorageUtil.isForbidden("photo.jpg"));
        assertFalse(FileStorageUtil.isForbidden("sheet.xlsx"));
    }

    @Test
    public void testAllowedImageValidation() {
        assertTrue(FileStorageUtil.isAllowedImage("pic.jpg", "image/jpeg"));
        assertTrue(FileStorageUtil.isAllowedImage("pic.jpeg", "image/jpeg"));
        assertTrue(FileStorageUtil.isAllowedImage("pic.png", "image/png"));
        assertTrue(FileStorageUtil.isAllowedImage("pic.webp", "image/webp"));
        assertTrue(FileStorageUtil.isAllowedImage("pic.gif", "image/gif"));

        assertFalse(FileStorageUtil.isAllowedImage("pic.exe", "image/jpeg"));
        assertFalse(FileStorageUtil.isAllowedImage("pic.jsp", "text/plain"));
        assertFalse(FileStorageUtil.isAllowedImage("pic.pdf", "application/pdf"));
    }

    @Test
    public void testAllowedFileValidation() {
        assertTrue(FileStorageUtil.isAllowedFile("report.pdf"));
        assertTrue(FileStorageUtil.isAllowedFile("notes.txt"));
        assertTrue(FileStorageUtil.isAllowedFile("contract.docx"));
        assertTrue(FileStorageUtil.isAllowedFile("data.xlsx"));
        assertTrue(FileStorageUtil.isAllowedFile("archive.zip"));

        assertFalse(FileStorageUtil.isAllowedFile("virus.exe"));
        assertFalse(FileStorageUtil.isAllowedFile("backdoor.jsp"));
        assertFalse(FileStorageUtil.isAllowedFile("payload.bat"));
    }

    @Test
    public void testFormatFileSize() {
        assertEquals("500 B", FileStorageUtil.formatFileSize(500));
        assertEquals("1.0 KB", FileStorageUtil.formatFileSize(1024));
        assertEquals("1.5 MB", FileStorageUtil.formatFileSize(1024 * 1024 + 512 * 1024));
        assertEquals("10.0 MB", FileStorageUtil.formatFileSize(10 * 1024 * 1024));
    }
}
