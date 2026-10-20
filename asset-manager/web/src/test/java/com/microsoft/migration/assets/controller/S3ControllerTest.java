package com.microsoft.migration.assets.controller;

import com.microsoft.migration.assets.model.S3StorageItem;
import com.microsoft.migration.assets.service.StorageService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.test.web.servlet.MockMvc;

import java.io.ByteArrayInputStream;
import java.time.Instant;
import java.util.List;

import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.model;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.redirectedUrl;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.view;

// Keys with dots guard against the path suffix matching change in Spring 6 (C-08).
@WebMvcTest(S3Controller.class)
class S3ControllerTest {

    private static final String KEY = "photo.final.jpg";

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private StorageService storageService;

    @Test
    void viewPageKeepsDotsInKey() throws Exception {
        S3StorageItem item = new S3StorageItem(KEY, KEY, 3L, Instant.now(), Instant.now(), "/storage/view/" + KEY);
        when(storageService.listObjects()).thenReturn(List.of(item));

        mockMvc.perform(get("/storage/view-page/" + KEY))
                .andExpect(status().isOk())
                .andExpect(view().name("view"))
                .andExpect(model().attribute("object", item));
    }

    @Test
    void viewReturnsContentForKeyWithDots() throws Exception {
        when(storageService.getObject(KEY)).thenReturn(new ByteArrayInputStream(new byte[] {1, 2, 3}));

        mockMvc.perform(get("/storage/view/" + KEY))
                .andExpect(status().isOk())
                .andExpect(content().bytes(new byte[] {1, 2, 3}));
    }

    @Test
    void deleteUsesFullKeyWithDots() throws Exception {
        mockMvc.perform(post("/storage/delete/" + KEY))
                .andExpect(status().is3xxRedirection())
                .andExpect(redirectedUrl("/storage"));

        verify(storageService).deleteObject(KEY);
    }
}
