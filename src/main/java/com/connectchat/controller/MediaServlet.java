package com.connectchat.controller;

import com.connectchat.util.FileStorageUtil;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.nio.charset.StandardCharsets;

@WebServlet("/media")
public class MediaServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String type = request.getParameter("type"); // "profile" or "group"
        String file = request.getParameter("file");

        String subFolder = "group".equalsIgnoreCase(type) ? "groups" : "profiles";
        File targetFile = null;

        if (file != null && !file.trim().isEmpty() && !file.equals("default.png") && !file.equals("group-default.png")) {
            targetFile = FileStorageUtil.getFile(subFolder, file);
        }

        if (targetFile != null && targetFile.exists()) {
            String mime = getServletContext().getMimeType(targetFile.getName());
            if (mime == null) {
                mime = "image/jpeg";
            }
            response.setContentType(mime);
            response.setContentLengthLong(targetFile.length());
            response.setHeader("Cache-Control", "public, max-age=86400");

            try (FileInputStream in = new FileInputStream(targetFile);
                 OutputStream out = response.getOutputStream()) {
                in.transferTo(out);
            }
            return;
        }

        // Return a clean inline SVG avatar if image is missing or default
        boolean isGroup = "group".equalsIgnoreCase(type);
        String name = request.getParameter("name");
        String initial = (name != null && !name.trim().isEmpty())
                ? name.trim().substring(0, 1).toUpperCase()
                : (isGroup ? "G" : "U");

        String bg1 = isGroup ? "#10b981" : "#6366f1";
        String bg2 = isGroup ? "#059669" : "#4f46e5";

        String svg = "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"128\" height=\"128\" viewBox=\"0 0 128 128\">"
                + "<defs>"
                + "<linearGradient id=\"grad\" x1=\"0%\" y1=\"0%\" x2=\"100%\" y2=\"100%\">"
                + "<stop offset=\"0%\" stop-color=\"" + bg1 + "\" />"
                + "<stop offset=\"100%\" stop-color=\"" + bg2 + "\" />"
                + "</linearGradient>"
                + "</defs>"
                + "<rect width=\"128\" height=\"128\" rx=\"64\" fill=\"url(#grad)\" />"
                + "<text x=\"50%\" y=\"54%\" font-family=\"Arial, sans-serif\" font-size=\"52\" font-weight=\"bold\" fill=\"#ffffff\" dominant-baseline=\"middle\" text-anchor=\"middle\">"
                + initial
                + "</text>"
                + "</svg>";

        byte[] svgBytes = svg.getBytes(StandardCharsets.UTF_8);
        response.setContentType("image/svg+xml");
        response.setContentLength(svgBytes.length);
        response.setHeader("Cache-Control", "public, max-age=86400");
        try (OutputStream out = response.getOutputStream()) {
            out.write(svgBytes);
        }
    }
}
