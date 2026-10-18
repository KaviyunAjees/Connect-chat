package com.connectchat;

import com.connectchat.util.HtmlUtil;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

public class HtmlUtilTest {

    @Test
    public void testHtmlEscape() {
        assertEquals("", HtmlUtil.escape(null));
        assertEquals("Hello World", HtmlUtil.escape("Hello World"));
        assertEquals("&lt;script&gt;alert(1)&lt;/script&gt;", HtmlUtil.escape("<script>alert(1)</script>"));
        assertEquals("Tom &amp; Jerry", HtmlUtil.escape("Tom & Jerry"));
        assertEquals("&quot;Hello&quot; &amp; &#x27;World&#x27;", HtmlUtil.escape("\"Hello\" & 'World'"));
    }
}
