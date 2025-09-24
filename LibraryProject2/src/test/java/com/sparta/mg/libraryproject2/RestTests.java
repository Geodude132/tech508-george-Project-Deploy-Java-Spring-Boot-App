package com.sparta.mg.libraryproject2;

import com.sparta.mg.libraryproject2.controller.AuthorController;
import com.sparta.mg.libraryproject2.model.entities.Author;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.web.reactive.server.WebTestClient;

import static org.junit.jupiter.api.Assertions.assertEquals;

@SpringBootTest
public class RestTests {

    private WebTestClient testClient;

    @Autowired
    private AuthorController authorController;

    @BeforeEach
    void setup() {
        testClient = WebTestClient.bindToController(authorController).build();
    }

    @Test
    @DisplayName("Check that the status code is 200")
    void checkThatTheStatusCodeIs200() {
        testClient
                .get()
                .uri("https://localhost:5000/authors")
                .exchange()
                .expectStatus()
                .isEqualTo(200);
    }

    @Test
    @DisplayName("Check that the first author is Phil")
    void checkThatTheFirstAuthorIsPhil() {
        testClient
                .get()
                .uri("https://localhost:5000/author/1")
                .exchange()
                .expectBody(Author.class)
                .value(author -> assertEquals("Phil", author.getFullName()));
    }
}
