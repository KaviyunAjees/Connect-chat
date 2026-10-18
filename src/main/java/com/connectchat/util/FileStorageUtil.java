package com.connectchat.util;

import jakarta.servlet.http.Part;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Locale;
import java.util.Set;
import java.util.UUID;

public class FileStorageUtil {

    private static final Set<String> FORBIDDEN_EXTENSIONS = new HashSet<>(Arrays.asList(
            "exe", "bat", "cmd", "sh", "jsp", "jspx", "war", "jar", "class",
            "php", "py", "pl", "dll", "com", "scr", "msi", "vbs", "ps1", "cgi",
            "asp", "aspx", "shtml", "phtml", "svg", "htm", "html", "js"
    ));

    private static final Set<String> ALLOWED_IMAGE_EXTENSIONS = new HashSet<>(Arrays.asList(
            "jpg", "jpeg", "png", "webp", "gif"
    ));

    private static final Set<String> ALLOWED_IMAGE_MIMES = new HashSet<>(Arrays.asList(
            "image/jpeg", "image/png", "image/webp", "image/gif"
    ));

    private static final Set<String> ALLOWED_FILE_EXTENSIONS = new HashSet<>(Arrays.asList(
            "pdf", "txt", "doc", "docx", "xls", "xlsx", "ppt", "pptx",
            "csv", "zip", "rar", "7z", "jpg", "jpeg", "png", "webp", "gif", "mp3", "mp4", "wav"
    ));

    public static final long MAX_PROFILE_IMAGE_SIZE = 5 * 1024 * 1024; // 5 MB
    public static final long MAX_PHOTO_MESSAGE_SIZE = 10 * 1024 * 1024; // 10 MB
    public static final long MAX_ATTACHMENT_SIZE = 25 * 1024 * 1024; // 25 MB

    public static String getStorageBasePath() {
        String customPath = System.getenv("UPLOAD_DIR");
        if (customPath == null || customPath.trim().isEmpty()) {
            customPath = System.getProperty("upload.dir");
        }
        if (customPath != null && !customPath.trim().isEmpty()) {
            return customPath.trim();
        }
        String userHome = System.getProperty("user.home");
        return Paths.get(userHome, ".connectchat", "uploads").toString();
    }

    public static File getStorageDirectory(String subFolder) {
        File dir = new File(getStorageBasePath(), subFolder);
        if (!dir.exists()) {
            dir.mkdirs();
        }
        return dir;
    }

    public static String getExtension(String fileName) {
        if (fileName == null || !fileName.contains(".")) {
            return "";
        }
        return fileName.substring(fileName.lastIndexOf(".") + 1).toLowerCase(Locale.ROOT).trim();
    }

    public static String sanitizeFileName(String fileName) {
        if (fileName == null) {
            return "file";
        }
        // Remove path traversal characters
        String clean = new File(fileName).getName();
        clean = clean.replaceAll("[^a-zA-Z0-9._-]", "_");
        if (clean.isEmpty()) {
            clean = "file";
        }
        return clean;
    }

    public static boolean isForbidden(String fileName) {
        String ext = getExtension(fileName);
        return FORBIDDEN_EXTENSIONS.contains(ext);
    }

    public static boolean isAllowedImage(String fileName, String mimeType) {
        String ext = getExtension(fileName);
        if (!ALLOWED_IMAGE_EXTENSIONS.contains(ext)) {
            return false;
        }
        if (mimeType != null && !mimeType.trim().isEmpty()) {
            return ALLOWED_IMAGE_MIMES.contains(mimeType.toLowerCase(Locale.ROOT));
        }
        return true;
    }

    public static boolean isAllowedFile(String fileName) {
        String ext = getExtension(fileName);
        if (isForbidden(fileName)) {
            return false;
        }
        return ALLOWED_FILE_EXTENSIONS.contains(ext);
    }

    public static String storeFile(Part part, String subFolder) throws IOException {
        String originalName = sanitizeFileName(part.getSubmittedFileName());
        if (isForbidden(originalName)) {
            throw new IllegalArgumentException("File type is not permitted for upload.");
        }

        String ext = getExtension(originalName);
        String uniqueName = UUID.randomUUID().toString() + (ext.isEmpty() ? "" : "." + ext);

        File dir = getStorageDirectory(subFolder);
        Path targetPath = new File(dir, uniqueName).toPath();

        try (InputStream in = part.getInputStream()) {
            Files.copy(in, targetPath, StandardCopyOption.REPLACE_EXISTING);
        }

        return uniqueName;
    }

    public static File getFile(String subFolder, String fileName) {
        if (fileName == null || fileName.contains("..") || fileName.contains("/") || fileName.contains("\\")) {
            return null;
        }
        File dir = getStorageDirectory(subFolder);
        File file = new File(dir, fileName);
        if (file.exists() && file.isFile()) {
            return file;
        }
        return null;
    }

    public static String formatFileSize(long bytes) {
        if (bytes < 1024) {
            return bytes + " B";
        }
        int exp = (int) (Math.log(bytes) / Math.log(1024));
        char pre = "KMGTPE".charAt(exp - 1);
        return String.format(Locale.ROOT, "%.1f %cB", bytes / Math.pow(1024, exp), pre);
    }
}
