package com.sparta.mg.libraryproject2;

import com.sparta.mg.libraryproject2.model.repositories.AuthorRepository;
import com.sparta.mg.libraryproject2.model.repositories.BookRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

@SpringBootTest
class RepositoryTests {

    @Autowired
    private AuthorRepository authorRepository;

    @Autowired
    private BookRepository bookRepository;


    @Test
    @DisplayName("Check that there are 4 authors")
    void checkFor4Authors() {
        assertEquals(4, authorRepository.findAll().size());
    }

    @Test
    @DisplayName("Check there is an author called Manish")
    void checkThereIsAnAuthorCalledManish() {
        authorRepository.findAuthorsByFullName("Manish")
                .forEach(author -> assertTrue(author.getFullName().equals("Manish")));
    }
}
