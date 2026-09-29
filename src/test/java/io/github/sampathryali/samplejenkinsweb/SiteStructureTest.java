package io.github.sampathryali.samplejenkinsweb;

import static org.junit.jupiter.api.Assertions.assertTrue;

import java.nio.file.Files;
import java.nio.file.Path;

import org.junit.jupiter.api.Test;

class SiteStructureTest {

  @Test
  void indexHtmlExistsInWebAppLayout() {
    Path indexHtml = Path.of("src", "main", "webapp", "index.html");
    assertTrue(Files.exists(indexHtml), "src/main/webapp/index.html should exist");
  }
}
